import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';

void main() {
  group('AppThemeMode', () {
    test('has exactly 3 values', () {
      expect(AppThemeMode.values, hasLength(3));
    });

    test('exhaustive switch over all variants', () {
      for (final mode in AppThemeMode.values) {
        final label = switch (mode) {
          AppThemeMode.system => 'system',
          AppThemeMode.light => 'light',
          AppThemeMode.dark => 'dark',
        };
        expect(label, isNotEmpty);
      }
    });
  });

  group('UserSettings defaults', () {
    test('applies documented defaults', () {
      const settings = UserSettings();

      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.defaultMaxHr, 190);
      expect(settings.isBiometricLockEnabled, isFalse);
      expect(settings.isLocked, isFalse);
      expect(settings.isOnboardingCompleted, isFalse);
      expect(settings.isCrashReportingEnabled, isTrue);
      expect(settings.isAnalyticsEnabled, isTrue);
    });
  });

  group('UserSettings copyWith', () {
    test('returns equal values when no args', () {
      const settings = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 175,
        isBiometricLockEnabled: true,
        isLocked: true,
        isOnboardingCompleted: true,
        isCrashReportingEnabled: false,
        isAnalyticsEnabled: false,
      );

      expect(settings.copyWith(), settings);
    });

    test('overrides each field independently', () {
      const base = UserSettings();

      expect(
        base.copyWith(themeMode: AppThemeMode.light).themeMode,
        AppThemeMode.light,
      );
      expect(base.copyWith(defaultMaxHr: 200).defaultMaxHr, 200);
      expect(
        base.copyWith(isBiometricLockEnabled: true).isBiometricLockEnabled,
        isTrue,
      );
      expect(base.copyWith(isLocked: true).isLocked, isTrue);
      expect(
        base.copyWith(isOnboardingCompleted: true).isOnboardingCompleted,
        isTrue,
      );
      expect(
        base.copyWith(isCrashReportingEnabled: false).isCrashReportingEnabled,
        isFalse,
      );
      expect(
        base.copyWith(isAnalyticsEnabled: false).isAnalyticsEnabled,
        isFalse,
      );
    });
  });

  group('UserSettings == and hashCode', () {
    test('identical instances are equal', () {
      const settings = UserSettings();

      expect(settings == settings, isTrue);
    });

    test('same field values are equal with same hashCode', () {
      const a = UserSettings(themeMode: AppThemeMode.dark, defaultMaxHr: 180);
      const b = UserSettings(themeMode: AppThemeMode.dark, defaultMaxHr: 180);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('each field participates in equality', () {
      const base = UserSettings();

      expect(base == base.copyWith(themeMode: AppThemeMode.dark), isFalse);
      expect(base == base.copyWith(defaultMaxHr: 1), isFalse);
      expect(base == base.copyWith(isBiometricLockEnabled: true), isFalse);
      expect(base == base.copyWith(isLocked: true), isFalse);
      expect(base == base.copyWith(isOnboardingCompleted: true), isFalse);
      expect(base == base.copyWith(isCrashReportingEnabled: false), isFalse);
      expect(base == base.copyWith(isAnalyticsEnabled: false), isFalse);
    });

    test('returns false for other types', () {
      const settings = UserSettings();

      expect(settings, isNot(equals(Object())));
    });
  });
}
