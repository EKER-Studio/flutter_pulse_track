import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/application/settings_providers.dart';

part 'app_settings_notifier.g.dart';

/// Manages application-wide user settings and provides methods to mutate preferences.
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  UserSettings build() {
    try {
      final repository = ref.watch(userSettingsRepositoryProvider);
      final subscription = repository.watchSettings().listen((settings) {
        // Preserve ephemeral lock state across DB emissions.
        final currentLocked = state.isLocked;
        state = settings.copyWith(isLocked: currentLocked);
      });
      ref.onDispose(subscription.cancel);
    } catch (_) {
      // In tests where Isar is not overridden, fall back to in-memory defaults.
    }

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

  /// Updates whether biometric lock is enabled and persists it.
  ///
  /// @param enabled Whether biometric protection is enabled.
  Future<void> updateBiometricLock(bool enabled) async {
    final repository = ref.read(userSettingsRepositoryProvider);
    final updated = state.copyWith(isBiometricLockEnabled: enabled);
    state = updated;
    await repository.saveSettings(updated);
  }

  /// Sets the ephemeral locked state (not persisted).
  ///
  /// @param locked Whether the app should show the biometric shield.
  void setLocked(bool locked) {
    state = state.copyWith(isLocked: locked);
  }

  /// Marks onboarding as completed and persists it.
  Future<void> completeOnboarding() async {
    final repository = ref.read(userSettingsRepositoryProvider);
    final updated = state.copyWith(isOnboardingCompleted: true);
    state = updated;
    await repository.saveSettings(updated);
  }
}
