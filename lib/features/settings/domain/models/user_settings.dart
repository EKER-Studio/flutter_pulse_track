import 'app_theme_mode.dart';

/// Immutable user preferences and global workout configuration.
class UserSettings {
  /// Current visual theme mode.
  final AppThemeMode themeMode;

  /// Default maximum heart rate in BPM used for zone thresholds calculation.
  final int defaultMaxHr;

  /// Creates a [UserSettings] instance.
  const UserSettings({
    this.themeMode = AppThemeMode.system,
    this.defaultMaxHr = 190,
  });

  /// Creates a copy of [UserSettings] with the given fields replaced.
  UserSettings copyWith({
    AppThemeMode? themeMode,
    int? defaultMaxHr,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultMaxHr: defaultMaxHr ?? this.defaultMaxHr,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          defaultMaxHr == other.defaultMaxHr;

  @override
  int get hashCode => Object.hash(themeMode, defaultMaxHr);
}
