import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/infrastructure/repositories/isar_user_settings_repository.dart';

part 'app_settings_notifier.g.dart';

/// Manages application-wide user settings and provides methods to mutate preferences.
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  UserSettings build() {
    final repository = ref.watch(userSettingsRepositoryProvider);
    final subscription = repository.watchSettings().listen((settings) {
      state = settings;
    });
    ref.onDispose(subscription.cancel);

    return const UserSettings();
  }

  /// Updates the active theme mode and persists it to database.
  ///
  /// @param mode The selected theme mode.
  Future<void> updateTheme(AppThemeMode mode) async {
    final repository = ref.read(userSettingsRepositoryProvider);
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    await repository.saveSettings(updated);
  }

  /// Updates the default maximum heart rate in BPM and persists it to database.
  ///
  /// @param maxHr Target max heart rate in beats per minute.
  Future<void> updateMaxHr(int maxHr) async {
    final repository = ref.read(userSettingsRepositoryProvider);
    final updated = state.copyWith(defaultMaxHr: maxHr);
    state = updated;
    await repository.saveSettings(updated);
  }
}
