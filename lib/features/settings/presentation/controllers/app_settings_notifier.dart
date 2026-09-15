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

  /// Applies [updated] optimistically, rolling back to the previous state
  /// if persistence fails so the UI never shows an unsaved value.
  ///
  /// Rethrows the persistence error so callers can surface feedback.
  Future<void> _persist(UserSettings updated) async {
    final previous = state;
    state = updated;
    try {
      await ref.read(userSettingsRepositoryProvider).saveSettings(updated);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  /// Updates the active theme mode and persists it to database.
  ///
  /// @param mode The selected theme mode.
  Future<void> updateTheme(AppThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  /// Updates the default maximum heart rate in BPM and persists it to database.
  ///
  /// @param maxHr Target max heart rate in beats per minute.
  Future<void> updateMaxHr(int maxHr) =>
      _persist(state.copyWith(defaultMaxHr: maxHr));

  /// Updates whether biometric lock is enabled and persists it.
  ///
  /// @param enabled Whether biometric protection is enabled.
  Future<void> updateBiometricLock(bool enabled) =>
      _persist(state.copyWith(isBiometricLockEnabled: enabled));

  /// Sets the ephemeral locked state (not persisted).
  ///
  /// @param locked Whether the app should show the biometric shield.
  void setLocked(bool locked) {
    state = state.copyWith(isLocked: locked);
  }

  /// Marks onboarding as completed and persists it.
  Future<void> completeOnboarding() =>
      _persist(state.copyWith(isOnboardingCompleted: true));
}
