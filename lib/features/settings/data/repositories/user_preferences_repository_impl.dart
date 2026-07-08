import 'package:isar_community/isar.dart';

import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../mappers/user_preferences_mapper.dart';
import '../models/user_preferences_model.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  UserPreferencesRepositoryImpl(this._isar);

  final Isar _isar;

  UserPreferences _mapOrDefault(UserPreferencesModel? model) {
    return model?.toEntity() ?? UserPreferences.defaults();
  }

  Future<UserPreferencesModel> _getOrCreateModel() async {
    final existing = await _isar.userPreferencesModels.get(
      userPreferencesSingletonId,
    );

    if (existing != null) {
      return existing;
    }

    final model = UserPreferences.defaults().toModel();
    await _isar.userPreferencesModels.put(model);
    return model;
  }

  @override
  Stream<UserPreferences> watch() {
    return _isar.userPreferencesModels
        .watchObject(userPreferencesSingletonId, fireImmediately: true)
        .map(_mapOrDefault);
  }

  @override
  Future<UserPreferences> get() async {
    final model = await _isar.userPreferencesModels.get(
      userPreferencesSingletonId,
    );
    return _mapOrDefault(model);
  }

  @override
  Future<void> updateThemeMode(UserThemeMode themeMode) async {
    await _isar.writeTxn(() async {
      final model = await _getOrCreateModel();
      model.themeMode = themeMode.name;
      await _isar.userPreferencesModels.put(model);
    });
  }

  @override
  Future<void> updateNotificationsEnabled(bool isEnabled) async {
    await _isar.writeTxn(() async {
      final model = await _getOrCreateModel();
      model.isNotificationsEnabled = isEnabled;
      await _isar.userPreferencesModels.put(model);
    });
  }
}
