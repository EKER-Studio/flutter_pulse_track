import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/application/service_providers.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/core/utils/crash_reporter.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/energy_unit.dart';
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
      final subscription = repository.watchSettings().listen(
        (settings) {
          // Preserve ephemeral lock state across DB emissions.
          final currentLocked = state.isLocked;
          state = settings.copyWith(isLocked: currentLocked);
          AppCrashReporter.setCollectionEnabled(
            settings.isCrashReportingEnabled,
          );
        },
        onError: (Object error, StackTrace stack) {
          log.e(
            '[AppSettingsNotifier] watchSettings stream error',
            error: error,
            stackTrace: stack,
          );
        },
      );
      ref.onDispose(subscription.cancel);
    } on Object catch (e, st) {
      // In tests where Isar is not overridden, fall back to in-memory defaults.
      log.w(
        '[AppSettingsNotifier] watchSettings unavailable — using defaults',
        error: e,
        stackTrace: st,
      );
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
    } on Object catch (e, st) {
      log.w(
        '[AppSettingsNotifier] persistence failed — rolling back',
        error: e,
        stackTrace: st,
      );
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

  /// Updates the energy measurement unit and persists it to database.
  ///
  /// @param unit The selected energy unit.
  Future<void> updateEnergyUnit(EnergyUnit unit) =>
      _persist(state.copyWith(energyUnit: unit));

  /// Updates whether live chart vertical scale defaults to auto-zoomed and persists it.
  ///
  /// @param zoomed Whether default chart zoom is enabled.
  Future<void> updateDefaultChartZoomed(bool zoomed) =>
      _persist(state.copyWith(defaultChartZoomed: zoomed));

  /// Updates whether biometric lock is enabled and persists it.
  ///
  /// @param enabled Whether biometric protection is enabled.
  Future<void> updateBiometricLock(bool enabled) =>
      _persist(state.copyWith(isBiometricLockEnabled: enabled));

  /// Updates whether anonymous crash reporting is enabled and synchronizes collection.
  ///
  /// @param enabled Whether Crashlytics collection is enabled.
  Future<void> updateCrashReporting(bool enabled) async {
    await _persist(state.copyWith(isCrashReportingEnabled: enabled));
    AppCrashReporter.setCollectionEnabled(enabled);
    try {
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          enabled,
        );
      }
    } on Object catch (e, st) {
      // Best-effort in test/uninitialized environments.
      log.d(
        '[AppSettingsNotifier] Crashlytics toggle skipped',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Updates whether anonymous usage analytics are enabled and synchronizes collection.
  ///
  /// @param enabled Whether Analytics collection is enabled.
  Future<void> updateAnalytics(bool enabled) async {
    await _persist(state.copyWith(isAnalyticsEnabled: enabled));
    try {
      if (kReleaseMode) {
        await ref.read(analyticsServiceProvider).setCollectionEnabled(enabled);
      }
    } on Object catch (e, st) {
      // Best-effort in test/uninitialized environments.
      log.d(
        '[AppSettingsNotifier] Analytics toggle skipped',
        error: e,
        stackTrace: st,
      );
    }
  }

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
