import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/infrastructure/storage/isar_provider.dart';
import 'features/workout/infrastructure/models/device_profile_dto.dart';
import 'features/workout/infrastructure/models/workout_session_dto.dart';

/// Application entry point.
///
/// Execution sequence:
/// 1. Ensures Flutter widget bindings are initialized.
/// 2. Resolves the platform-specific application documents directory.
/// 3. Opens the Isar database with [DeviceProfileDto] and [WorkoutSessionDto] schemas.
/// 4. Overrides [isarProvider] in the root [ProviderScope] so the rest of the app
///    can access the database synchronously without awaiting disk I/O.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    DeviceProfileDtoSchema,
    WorkoutSessionDtoSchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const App(),
    ),
  );
}
