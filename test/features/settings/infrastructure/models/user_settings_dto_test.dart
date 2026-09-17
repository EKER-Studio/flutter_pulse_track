import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/infrastructure/models/user_settings_dto.dart';

void main() {
  group('UserSettingsDto defaults', () {
    test('uses singleton id and app defaults', () {
      final dto = UserSettingsDto();

      expect(dto.id, 1);
      expect(dto.themeMode, AppThemeMode.system);
      expect(dto.defaultMaxHr, 190);
      expect(dto.isBiometricLockEnabled, isFalse);
      expect(dto.isOnboardingCompleted, isFalse);
    });
  });

  group('UserSettingsDto.fromDomain', () {
    test('copies every persisted field and pins id to 1', () {
      const settings = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 175,
        isBiometricLockEnabled: true,
        isLocked: true,
        isOnboardingCompleted: true,
      );

      final dto = UserSettingsDto.fromDomain(settings);

      expect(dto.id, 1);
      expect(dto.themeMode, AppThemeMode.dark);
      expect(dto.defaultMaxHr, 175);
      expect(dto.isBiometricLockEnabled, isTrue);
      expect(dto.isOnboardingCompleted, isTrue);
    });

    test('round-trips each theme mode', () {
      for (final mode in AppThemeMode.values) {
        final dto = UserSettingsDto.fromDomain(UserSettings(themeMode: mode));

        expect(dto.themeMode, mode);
        expect(dto.toDomain().themeMode, mode);
      }
    });
  });

  group('UserSettingsDto.toDomain', () {
    test('maps every field back to the domain model', () {
      final dto = UserSettingsDto()
        ..themeMode = AppThemeMode.light
        ..defaultMaxHr = 200
        ..isBiometricLockEnabled = true
        ..isOnboardingCompleted = true;

      final domain = dto.toDomain();

      expect(domain.themeMode, AppThemeMode.light);
      expect(domain.defaultMaxHr, 200);
      expect(domain.isBiometricLockEnabled, isTrue);
      expect(domain.isOnboardingCompleted, isTrue);
      // Ephemeral lock state is never persisted.
      expect(domain.isLocked, isFalse);
    });

    test('full round-trip preserves settings', () {
      const settings = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 165,
        isBiometricLockEnabled: true,
        isOnboardingCompleted: true,
      );

      expect(UserSettingsDto.fromDomain(settings).toDomain(), settings);
    });
  });
}
