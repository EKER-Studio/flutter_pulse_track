import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/storage/isar_provider.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/domain/repositories/user_settings_repository.dart';

import '../models/user_settings_dto.dart';

part 'isar_user_settings_repository.g.dart';

/// Concrete implementation of [UserSettingsRepository] backed by Isar.
class IsarUserSettingsRepository implements UserSettingsRepository {
  final Isar _isar;

  /// Creates an [IsarUserSettingsRepository] with the given [_isar] instance.
  IsarUserSettingsRepository(this._isar);

  @override
  Future<UserSettings> getSettings() async {
    final dto = await _isar.userSettingsDtos.get(1);
    return dto?.toDomain() ?? const UserSettings();
  }

  @override
  Stream<UserSettings> watchSettings() {
    return _isar.userSettingsDtos
        .watchObject(1, fireImmediately: true)
        .map((dto) => dto?.toDomain() ?? const UserSettings());
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final dto = UserSettingsDto.fromDomain(settings);
    await _isar.writeTxn(() async {
      await _isar.userSettingsDtos.put(dto);
    });
  }
}

/// Provides the active [UserSettingsRepository] instance globally.
@Riverpod(keepAlive: true)
UserSettingsRepository userSettingsRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return IsarUserSettingsRepository(isar);
}
