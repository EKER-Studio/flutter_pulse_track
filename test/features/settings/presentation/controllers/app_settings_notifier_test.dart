import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:pulse_track/features/settings/application/settings_providers.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';

class InMemoryUserSettingsRepository implements UserSettingsRepository {
  UserSettings _settings = const UserSettings();
  final _controller = StreamController<UserSettings>.broadcast();

  /// When set, [saveSettings] throws this instead of persisting.
  Object? saveError;

  /// When true, [watchSettings] throws instead of returning the stream.
  bool throwOnWatch = false;

  @override
  Future<UserSettings> getSettings() async => _settings;

  @override
  Stream<UserSettings> watchSettings() {
    if (throwOnWatch) throw StateError('no database');
    return _controller.stream;
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    if (saveError != null) throw saveError!;
    _settings = settings;
    _controller.add(settings);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late InMemoryUserSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryUserSettingsRepository();
    container = ProviderContainer(
      overrides: [userSettingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    repository.dispose();
    container.dispose();
  });

  group('AppSettingsNotifier', () {
    test('initial state defaults to UserSettings', () {
      final state = container.read(appSettingsProvider);
      expect(state.themeMode, AppThemeMode.system);
      expect(state.defaultMaxHr, 190);
    });

    test(
      'updateTheme mutates state and invokes repository.saveSettings',
      () async {
        await container
            .read(appSettingsProvider.notifier)
            .updateTheme(AppThemeMode.dark);

        final state = container.read(appSettingsProvider);
        expect(state.themeMode, AppThemeMode.dark);

        final persisted = await repository.getSettings();
        expect(persisted.themeMode, AppThemeMode.dark);
      },
    );

    test(
      'updateMaxHr mutates state and invokes repository.saveSettings',
      () async {
        await container.read(appSettingsProvider.notifier).updateMaxHr(175);

        final state = container.read(appSettingsProvider);
        expect(state.defaultMaxHr, 175);

        final persisted = await repository.getSettings();
        expect(persisted.defaultMaxHr, 175);
      },
    );

    test('watchSettings stream updates state reactively', () async {
      final sub = container.listen(appSettingsProvider, (_, _) {});
      expect(
        container.read(appSettingsProvider).themeMode,
        AppThemeMode.system,
      );

      await repository.saveSettings(
        const UserSettings(themeMode: AppThemeMode.light, defaultMaxHr: 200),
      );

      await pumpEventQueue();

      final updatedState = container.read(appSettingsProvider);
      expect(updatedState.themeMode, AppThemeMode.light);
      expect(updatedState.defaultMaxHr, 200);
      sub.close();
    });

    test('failed save rolls back optimistic state and rethrows', () async {
      repository.saveError = Exception('disk full');

      await expectLater(
        container.read(appSettingsProvider.notifier).updateMaxHr(175),
        throwsException,
      );

      final state = container.read(appSettingsProvider);
      expect(state.defaultMaxHr, 190);

      final persisted = await repository.getSettings();
      expect(persisted.defaultMaxHr, 190);
    });

    test('updateBiometricLock persists the flag', () async {
      await container
          .read(appSettingsProvider.notifier)
          .updateBiometricLock(true);

      expect(
        container.read(appSettingsProvider).isBiometricLockEnabled,
        isTrue,
      );
      expect((await repository.getSettings()).isBiometricLockEnabled, isTrue);
    });

    test('completeOnboarding persists the flag', () async {
      await container.read(appSettingsProvider.notifier).completeOnboarding();

      expect(container.read(appSettingsProvider).isOnboardingCompleted, isTrue);
      expect((await repository.getSettings()).isOnboardingCompleted, isTrue);
    });

    test('setLocked toggles ephemeral state without persisting', () async {
      container.read(appSettingsProvider.notifier).setLocked(true);
      expect(container.read(appSettingsProvider).isLocked, isTrue);
      expect((await repository.getSettings()).isLocked, isFalse);

      container.read(appSettingsProvider.notifier).setLocked(false);
      expect(container.read(appSettingsProvider).isLocked, isFalse);
    });

    test('database emissions preserve the ephemeral lock state', () async {
      final sub = container.listen(appSettingsProvider, (_, _) {});
      container.read(appSettingsProvider.notifier).setLocked(true);

      await repository.saveSettings(
        const UserSettings(themeMode: AppThemeMode.light),
      );
      await pumpEventQueue();

      final state = container.read(appSettingsProvider);
      expect(state.themeMode, AppThemeMode.light);
      expect(state.isLocked, isTrue);
      sub.close();
    });

    test('build falls back to defaults when the repository throws', () {
      repository.throwOnWatch = true;

      final fresh = ProviderContainer(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(fresh.dispose);

      expect(fresh.read(appSettingsProvider), const UserSettings());
    });
  });
}
