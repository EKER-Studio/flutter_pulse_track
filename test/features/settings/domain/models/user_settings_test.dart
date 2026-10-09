import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/energy_unit.dart';
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

  group('EnergyUnit', () {
    test('has exactly 2 values', () {
      expect(EnergyUnit.values, hasLength(2));
    });

    test('exhaustive switch over all variants', () {
      for (final unit in EnergyUnit.values) {
        final label = switch (unit) {
          EnergyUnit.kcal => 'kcal',
          EnergyUnit.kj => 'kj',
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
      expect(settings.energyUnit, EnergyUnit.kcal);
      expect(settings.defaultChartZoomed, isFalse);
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
        energyUnit: EnergyUnit.kj,
        defaultChartZoomed: true,
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
      expect(
        base.copyWith(energyUnit: EnergyUnit.kj).energyUnit,
        EnergyUnit.kj,
      );
      expect(
        base.copyWith(defaultChartZoomed: true).defaultChartZoomed,
        isTrue,
      );
    });
  });

  group('UserSettings == and hashCode', () {
    test('identical instances are equal', () {
      const settings = UserSettings();

      expect(settings == settings, isTrue);
    });

    test('same field values are equal with same hashCode', () {
      const a = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 180,
        energyUnit: EnergyUnit.kj,
        defaultChartZoomed: true,
      );
      const b = UserSettings(
        themeMode: AppThemeMode.dark,
        defaultMaxHr: 180,
        energyUnit: EnergyUnit.kj,
        defaultChartZoomed: true,
      );

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
      expect(base == base.copyWith(energyUnit: EnergyUnit.kj), isFalse);
      expect(base == base.copyWith(defaultChartZoomed: true), isFalse);
    });

    test('returns false for other types', () {
      const settings = UserSettings();

      expect(settings, isNot(equals(Object())));
    });
  });
}
