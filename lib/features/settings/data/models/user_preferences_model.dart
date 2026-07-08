import 'package:isar_community/isar.dart';

part 'user_preferences_model.g.dart';

const userPreferencesSingletonId = 0;

@collection
class UserPreferencesModel {
  Id id = userPreferencesSingletonId;

  late String themeMode;

  bool isNotificationsEnabled = true;
}
