// Repository tests for IsarUserSettingsRepository backed by a real
// Isar instance in a temporary directory.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/infrastructure/models/user_settings_dto.dart';
import 'package:pulse_track/features/settings/infrastructure/repositories/isar_user_settings_repository.dart';

void main() {
  late Isar isar;
  late IsarUserSettingsRepository repository;
  late Directory tmpDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('isar_settings_test_');
    isar = await Isar.open([UserSettingsDtoSchema], directory: tmpDir.path);
    repository = IsarUserSettingsRepository(isar);
  });

  tearDown(() async {
    await isar.close();
    tmpDir.deleteSync(recursive: true);
  });

  group('getSettings', () {
    test('returns defaults when nothing is stored', () async {
      expect(await repository.getSettings(), const UserSettings());
    });

    test('returns the last saved settings', () async {
      const settings = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 175,
        isBiometricLockEnabled: true,
        isOnboardingCompleted: true,
      );
      await repository.saveSettings(settings);

      expect(await repository.getSettings(), settings);
    });
  });

  group('watchSettings', () {
    test('emits defaults immediately, then saved settings', () async {
      const settings = UserSettings(
        themeMode: AppThemeMode.light,
        defaultMaxHr: 180,
      );

      final expectation = expectLater(
        repository.watchSettings(),
        emitsInOrder([const UserSettings(), settings]),
      );
      await pumpEventQueue();
      await repository.saveSettings(settings);
      await expectation;
    });
  });
}
