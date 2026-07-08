import '../../domain/entities/user_preferences.dart';
import '../models/user_preferences_model.dart';

extension UserPreferencesModelMapper on UserPreferencesModel {
  UserPreferences toEntity() {
    return UserPreferences(
      themeMode: _themeModeFromStorage(themeMode),
      isNotificationsEnabled: isNotificationsEnabled,
    );
  }
}

extension UserPreferencesEntityMapper on UserPreferences {
  UserPreferencesModel toModel() {
    return UserPreferencesModel()
      ..id = userPreferencesSingletonId
      ..themeMode = themeMode.name
      ..isNotificationsEnabled = isNotificationsEnabled;
  }
}

UserThemeMode _themeModeFromStorage(String value) {
  return UserThemeMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => UserThemeMode.system,
  );
}
