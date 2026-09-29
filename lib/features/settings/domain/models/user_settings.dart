import 'app_theme_mode.dart';

/// Immutable user preferences and global workout configuration.
class UserSettings {
  /// Current visual theme mode.
  final AppThemeMode themeMode;

  /// Default maximum heart rate in BPM used for zone thresholds calculation.
  final int defaultMaxHr;

  /// Whether biometric app lock is enabled.
  final bool isBiometricLockEnabled;

  /// Whether the app is currently locked behind biometric shield.
  final bool isLocked;

  /// Whether onboarding wizard has been completed.
  final bool isOnboardingCompleted;

  /// Whether anonymous crash reporting via Firebase Crashlytics is enabled.
  final bool isCrashReportingEnabled;

  /// Whether anonymous interaction analytics via Firebase Analytics are enabled.
  final bool isAnalyticsEnabled;

  const UserSettings({
    this.themeMode = AppThemeMode.system,
    this.defaultMaxHr = 190,
    this.isBiometricLockEnabled = false,
    this.isLocked = false,
    this.isOnboardingCompleted = false,
    this.isCrashReportingEnabled = true,
    this.isAnalyticsEnabled = true,
  });

  /// Creates a copy of [UserSettings] with the given fields replaced.
  UserSettings copyWith({
    AppThemeMode? themeMode,
    int? defaultMaxHr,
    bool? isBiometricLockEnabled,
    bool? isLocked,
    bool? isOnboardingCompleted,
    bool? isCrashReportingEnabled,
    bool? isAnalyticsEnabled,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultMaxHr: defaultMaxHr ?? this.defaultMaxHr,
      isBiometricLockEnabled:
          isBiometricLockEnabled ?? this.isBiometricLockEnabled,
      isLocked: isLocked ?? this.isLocked,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isCrashReportingEnabled:
          isCrashReportingEnabled ?? this.isCrashReportingEnabled,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          defaultMaxHr == other.defaultMaxHr &&
          isBiometricLockEnabled == other.isBiometricLockEnabled &&
          isLocked == other.isLocked &&
          isOnboardingCompleted == other.isOnboardingCompleted &&
          isCrashReportingEnabled == other.isCrashReportingEnabled &&
          isAnalyticsEnabled == other.isAnalyticsEnabled;

  @override
  int get hashCode => Object.hash(
    themeMode,
    defaultMaxHr,
    isBiometricLockEnabled,
    isLocked,
    isOnboardingCompleted,
    isCrashReportingEnabled,
    isAnalyticsEnabled,
  );
}
