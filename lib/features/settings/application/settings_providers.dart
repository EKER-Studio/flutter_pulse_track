import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/storage/isar_provider.dart';
import 'package:pulse_track/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:pulse_track/features/settings/infrastructure/repositories/isar_user_settings_repository.dart';
import 'package:pulse_track/features/settings/infrastructure/services/csv_workout_import_service.dart';

part 'settings_providers.g.dart';

/// Provides the active [UserSettingsRepository] instance globally.
///
/// Lives in the application layer so presentation depends on the domain
/// contract, not on the Isar-backed implementation file.
@Riverpod(keepAlive: true)
UserSettingsRepository userSettingsRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return IsarUserSettingsRepository(isar);
}

/// Provides the [CsvWorkoutImportService] for CSV import from presentation.
///
/// Lives here (not in `infrastructure/services/csv_workout_import_service.dart`)
/// so presentation depends on the application layer, never on infrastructure.
@riverpod
CsvWorkoutImportService csvWorkoutImportService(Ref ref) {
  return const CsvWorkoutImportService();
}
