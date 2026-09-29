import 'package:isar_community/isar.dart';

import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';

part 'user_settings_dto.g.dart';

/// Isar database collection storing persistent user configuration.
@collection
class UserSettingsDto {
  UserSettingsDto();

  /// Singleton primary key. Always 1.
  Id id = 1;

  /// Active visual theme mode stored as an enumerated integer.
  @enumerated
  AppThemeMode themeMode = AppThemeMode.system;

  /// Default maximum heart rate in BPM.
  int defaultMaxHr = 190;

  /// Whether biometric lock is enabled.
  bool isBiometricLockEnabled = false;

  /// Whether onboarding has been completed.
  bool isOnboardingCompleted = false;

  /// Whether anonymous crash reporting via Firebase Crashlytics is enabled.
  bool isCrashReportingEnabled = true;

  /// Whether anonymous interaction analytics via Firebase Analytics are enabled.
  bool isAnalyticsEnabled = true;

  /// Converts this database entity to a pure domain [UserSettings] model.
  UserSettings toDomain() {
    return UserSettings(
      themeMode: themeMode,
      defaultMaxHr: defaultMaxHr,
      isBiometricLockEnabled: isBiometricLockEnabled,
      isOnboardingCompleted: isOnboardingCompleted,
      isCrashReportingEnabled: isCrashReportingEnabled,
      isAnalyticsEnabled: isAnalyticsEnabled,
    );
  }

  /// Creates a [UserSettingsDto] pre-populated from domain [settings].
  static UserSettingsDto fromDomain(UserSettings settings) {
    final dto = UserSettingsDto();
    dto.id = 1;
    dto.themeMode = settings.themeMode;
    dto.defaultMaxHr = settings.defaultMaxHr;
    dto.isBiometricLockEnabled = settings.isBiometricLockEnabled;
    dto.isOnboardingCompleted = settings.isOnboardingCompleted;
    dto.isCrashReportingEnabled = settings.isCrashReportingEnabled;
    dto.isAnalyticsEnabled = settings.isAnalyticsEnabled;
    return dto;
  }
}
