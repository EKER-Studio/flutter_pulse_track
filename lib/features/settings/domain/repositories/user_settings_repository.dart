import '../models/user_settings.dart';

/// Contract for persisting and retrieving user preferences.
abstract class UserSettingsRepository {
  /// Fetches the currently stored user preferences.
  Future<UserSettings> getSettings();

  /// Emits real-time changes whenever user preferences are updated.
  Stream<UserSettings> watchSettings();

  /// Persists modified user preferences.
  ///
  /// @param settings The updated preferences to store.
  Future<void> saveSettings(UserSettings settings);
}
