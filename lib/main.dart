import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/infrastructure/storage/isar_provider.dart';
import 'core/presentation/theme/app_colors.dart';
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
/// 5. Overrides [isarProvider] in the root [ProviderScope] so the rest of the app
///    can access the database synchronously without awaiting disk I/O.
///
/// If the database fails to open (corrupted file, broken migration), a minimal
/// error screen is displayed rather than letting the app crash with a hard
/// native stack trace.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([
      DeviceProfileDtoSchema,
      WorkoutSessionDtoSchema,
    ], directory: dir.path);

    final repo = WorkoutPersistenceRepository(isar);
    await repo.sanitizeCrashedSessions();

    runApp(
      ProviderScope(
        overrides: [isarProvider.overrideWithValue(isar)],
        child: const App(),
      ),
    );
  } catch (e) {
    runApp(_DatabaseErrorApp(error: e));
  }
}

/// Minimal error screen displayed when the Isar database cannot be opened.
///
/// This prevents a hard native crash on startup due to corrupted storage or
/// a broken migration, and instead shows a recoverable user-facing message.
class _DatabaseErrorApp extends StatelessWidget {
  const _DatabaseErrorApp({required this.error});

  final Object error;

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
                Text(
                  'Failed to open the local database:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
