import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';
import 'core/infrastructure/storage/isar_provider.dart';
import 'core/presentation/theme/app_colors.dart';

import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart'
    as domain;

import 'features/workout/infrastructure/models/device_profile_dto.dart';
import 'features/workout/infrastructure/models/workout_session_dto.dart';
import 'features/workout/infrastructure/repositories/workout_persistence_repository.dart';

/// Application entry point.
///
/// Execution sequence:
/// 1. Ensures Flutter widget bindings are initialized.
/// 2. Resolves the platform-specific application documents directory.
/// 3. Opens the Isar database with [DeviceProfileDto] and [WorkoutSessionDto] schemas.
/// 4. Sanitizes crashed / unclosed sessions from previous unexpected terminations.
/// 5. Overrides [isarProvider] and [domain.workoutPersistenceRepositoryProvider] in the root [ProviderScope] so the rest of the app
///    can access the database synchronously without awaiting disk I/O.
///
/// If the database fails to open (corrupted file, broken migration), a minimal
/// error screen is displayed rather than letting the app crash with a hard
/// native stack trace.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dir = await getApplicationDocumentsDirectory();
    // SECURITY-DECISION: Isar stores health data (BPM samples, device names) in
    // plaintext. Encryption-at-rest via Isar `encryptionKey` is intentionally
    // deferred — data is device-local, not backed up, and `flutter_secure_storage`
    // key management adds migration complexity. Re-evaluate before Play Store
    // release handling sensitive health data. See C-1.
    // Dual-open guard prevents "Isar already opened" on hot-restart.
    final isar =
        Isar.getInstance() ??
        await Isar.open([
          DeviceProfileDtoSchema,
          WorkoutSessionDtoSchema,
        ], directory: dir.path);

    final repo = WorkoutPersistenceRepository(isar);
    await repo.sanitizeCrashedSessions();

    runApp(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          domain.workoutPersistenceRepositoryProvider.overrideWithValue(repo),
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
