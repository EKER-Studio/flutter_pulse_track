import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/infrastructure/storage/database_module.dart';
import 'core/integrations/biometrics/biometric_lock_observer.dart';
import 'core/integrations/widgets/widget_sync_service.dart';
import 'core/navigation/app_router.dart';
import 'core/presentation/theme/app_theme.dart';
import 'features/settings/domain/models/app_theme_mode.dart';
import 'features/settings/presentation/controllers/app_settings_notifier.dart';
import 'features/workout/application/workout_providers.dart';
import 'l10n/app_localizations.dart';

/// Root widget that configures the MaterialApp with Material 3 theming and GoRouter navigation.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    final themeMode = switch (settings.themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return _BiometricObserverRegistrar(
      child: _WidgetSyncObserver(
        child: MaterialApp.router(
          title: 'PulseTrack',
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}

/// Registers [BiometricLockObserver] to handle background lock and DB integrity.
class _BiometricObserverRegistrar extends ConsumerStatefulWidget {
  final Widget child;

  const _BiometricObserverRegistrar({required this.child});

  @override
  ConsumerState<_BiometricObserverRegistrar> createState() =>
      _BiometricObserverRegistrarState();
}

class _BiometricObserverRegistrarState
    extends ConsumerState<_BiometricObserverRegistrar> {
  BiometricLockObserver? _observer;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    if (settings.isBiometricLockEnabled) {
      ref.read(appSettingsProvider.notifier).setLocked(true);
    }
    _observer = BiometricLockObserver(
      isBiometricLockEnabled: () =>
          ref.read(appSettingsProvider).isBiometricLockEnabled,
      isAppLocked: () => ref.read(appSettingsProvider).isLocked,
      onLockStateChanged: (locked) =>
          ref.read(appSettingsProvider.notifier).setLocked(locked),
      localizedReason: () => AppLocalizations.of(context).biometricAuthReason,
      verifyDatabaseIntegrity: () async {
        final result = await DatabaseModule.ensureInstanceIntegrity();
        return (reopened: result.reopened);
      },
    );
  }

  @override
  void dispose() {
    _observer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Synchronizes workout history to home widgets.
class _WidgetSyncObserver extends ConsumerStatefulWidget {
  final Widget child;
  const _WidgetSyncObserver({required this.child});

  @override
  ConsumerState<_WidgetSyncObserver> createState() =>
      _WidgetSyncObserverState();
}

class _WidgetSyncObserverState extends ConsumerState<_WidgetSyncObserver> {
  @override
  void initState() {
    super.initState();
    // Listen to workout history and push to widgets.
    ref.listenManual(watchWorkoutHistoryStreamProvider, (previous, next) {
      next.whenData((sessions) {
        WidgetSyncService.instance.updateWidgetData(sessions: sessions);
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
