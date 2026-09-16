import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/infrastructure/storage/database_module.dart';
import 'core/infrastructure/storage/isar_provider.dart';
import 'core/integrations/notifications/notification_service.dart';
import 'core/integrations/widgets/widget_sync_service.dart';
import 'core/presentation/theme/app_colors.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/crash_reporter.dart';
import 'firebase_options.dart';

import 'package:pulse_track/features/workout/application/workout_providers.dart'
    as app_providers;

import 'features/workout/domain/usecases/sanitize_crashed_sessions_usecase.dart';
import 'features/workout/infrastructure/repositories/workout_persistence_repository.dart';

/// Application entry point.
///
/// Execution sequence:
/// 1. Ensures Flutter widget bindings are initialized.
/// 2. Initializes Firebase infrastructure, Crashlytics error handlers, and Analytics.
/// 3. Resolves the platform-specific application documents directory.
/// 4. Opens the Isar database with [DeviceProfileDto] and [WorkoutSessionDto] schemas.
/// 5. Sanitizes crashed / unclosed sessions from previous unexpected terminations.
/// 6. Overrides [isarProvider] and [domain.workoutPersistenceRepositoryProvider] in the root [ProviderScope] so the rest of the app
///    can access the database synchronously without awaiting disk I/O.
///
/// If the database fails to open (corrupted file, broken migration), a minimal
/// error screen is displayed rather than letting the app crash with a hard
/// native stack trace.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by Flutter to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Enable Crashlytics and Analytics collection only in Release builds.
    // In Debug builds, collection is disabled to prevent developmental exceptions
    // and hot-restarts from distorting production metrics.
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      AppCrashReporter.setFirebaseAvailable(true);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      AppCrashReporter.setFirebaseAvailable(false);
    }
  } catch (e, st) {
    log.w(
      'Firebase initialization skipped or failed: $e',
      error: e,
      stackTrace: st,
    );
  }

  // Initialize widget and notification services.
  try {
    await WidgetSyncService.instance.initialize();
  } catch (e, stack) {
    await AppCrashReporter.recordError(
      e,
      stack,
      reason: 'WidgetSyncService initialization failed',
      fatal: false,
    );
  }

  try {
    await NotificationService.instance.initialize();
  } catch (e, stack) {
    await AppCrashReporter.recordError(
      e,
      stack,
      reason: 'NotificationService initialization failed',
      fatal: false,
    );
  }

  try {
    final isar = await DatabaseModule.initialize();

    final repo = WorkoutPersistenceRepository(isar);
    try {
      final sanitized = await SanitizeCrashedSessionsUseCase(repo).call();
      if (sanitized > 0) {
        log.i('Sanitized $sanitized crashed workout sessions on startup.');
      }
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Crashed workout session recovery failed',
        fatal: false,
      );
    }

    runApp(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          app_providers.workoutPersistenceRepositoryProvider.overrideWithValue(
            repo,
          ),
        ],
        child: const App(),
      ),
    );
  } catch (e, st) {
    log.e(
      'Failed to initialize Isar database on startup',
      error: e,
      stackTrace: st,
    );
    runApp(const _DatabaseErrorApp());
  }
}

/// Minimal error screen displayed when the Isar database cannot be opened.
///
/// This prevents a hard native crash on startup due to corrupted storage or
/// a broken migration, and instead shows a recoverable user-facing message.
class _DatabaseErrorApp extends StatelessWidget {
  const _DatabaseErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkerBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storage, size: 64, color: AppColors.accentRed),
                const SizedBox(height: 24),
                const Text(
                  'Database Error',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Keep English fallback here — _DatabaseErrorApp runs before
                // localization delegates are initialized (no BuildContext l10n).
                const Text(
                  'A critical database error occurred. Try restarting the app or clearing its cache.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
