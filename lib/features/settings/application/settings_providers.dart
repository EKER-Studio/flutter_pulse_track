import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/storage/isar_provider.dart';
import 'package:pulse_track/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:pulse_track/features/settings/infrastructure/repositories/isar_user_settings_repository.dart';

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
