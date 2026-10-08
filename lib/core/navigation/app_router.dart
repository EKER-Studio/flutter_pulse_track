import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/views/route_error_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/core/infrastructure/services/analytics_service.dart';
import 'package:pulse_track/features/settings/presentation/screens/licenses_screen.dart';
import 'package:pulse_track/features/settings/presentation/screens/settings_screen.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';
import 'package:pulse_track/core/presentation/screens/biometric_shield_screen.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:pulse_track/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:pulse_track/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pulse_track/features/statistics/presentation/screens/statistics_screen.dart';

part 'app_router.g.dart';

/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.
///
/// Settings changes refresh routing via [GoRouter.refreshListenable] instead
/// of `ref.watch`, so toggling a setting (e.g. the theme) re-evaluates
/// redirects without recreating the router and losing navigation state.
@riverpod
GoRouter appRouter(Ref ref) {
  final analyticsObserver = ref.watch(analyticsObserverProvider);
  final settingsRefresh = _SettingsRefreshListenable();
  ref.listen<UserSettings>(appSettingsProvider, (_, _) {
    settingsRefresh.notify();
  });
  ref.onDispose(settingsRefresh.dispose);

  UserSettings currentSettings() {
    try {
      return ref.read(appSettingsProvider);
    } on Object catch (_) {
      return const UserSettings();
    }
  }

  return GoRouter(
    initialLocation: '/',
    observers: [?analyticsObserver],
    refreshListenable: settingsRefresh,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        RouteErrorView(error: state.error),
    redirect: (context, state) {
      final settings = currentSettings();
      final isGoingToShield = state.matchedLocation == '/shield';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      if (settings.isLocked) {
        return isGoingToShield ? null : '/shield';
      }
      if (isGoingToShield) {
        return '/';
      }
      if (!settings.isOnboardingCompleted) {
        return isGoingToOnboarding ? null : '/onboarding';
      }
      if (isGoingToOnboarding) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/shield',
        name: 'shield',
        builder: (BuildContext context, GoRouterState state) =>
            const BiometricShieldScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (BuildContext context, GoRouterState state) =>
            const HrScannerView(),
      ),
      GoRoute(
        path: '/monitor',
        name: 'monitor',
        builder: (BuildContext context, GoRouterState state) {
          final deviceId = Uri.decodeComponent(
            state.uri.queryParameters['deviceId'] ?? '',
          );
          final deviceName = Uri.decodeComponent(
            state.uri.queryParameters['deviceName'] ?? '',
          );
          return HrMonitorView(deviceId: deviceId, deviceName: deviceName);
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (BuildContext context, GoRouterState state) =>
            const WorkoutHistoryView(),
        routes: <RouteBase>[
          GoRoute(
            path: 'details/:sessionId',
            name: 'workoutDetails',
            builder: (BuildContext context, GoRouterState state) {
              final extra = state.extra;
              if (extra is WorkoutSession) {
                return WorkoutDetailsView(session: extra);
              }
              final sessionIdStr = state.pathParameters['sessionId'];
              final sessionId = int.tryParse(sessionIdStr ?? '');
              if (sessionId != null) {
                return WorkoutDetailsLoaderView(sessionId: sessionId);
              }
              return const RouteErrorView();
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HrHomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                builder: (BuildContext context, GoRouterState state) =>
                    const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                name: 'statistics',
                builder: (BuildContext context, GoRouterState state) =>
                    const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'licenses',
                    name: 'settingsLicenses',
                    builder: (BuildContext context, GoRouterState state) =>
                        const LicensesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Fallback widget that loads a [WorkoutSession] from database by ID
/// when navigating via deep-link or cold boot where [GoRouterState.extra] is null.
class WorkoutDetailsLoaderView extends ConsumerWidget {
  const WorkoutDetailsLoaderView({required this.sessionId, super.key});

  /// Database ID of the workout session to load.
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return historyAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
      ),
      error: (error, stackTrace) => RouteErrorView(error: error),
      data: (sessions) {
        final session = sessions.where((s) => s.id == sessionId).firstOrNull;
        if (session != null) {
          return WorkoutDetailsView(session: session);
        }
        return const RouteErrorView();
      },
    );
  }
}

/// Notifies [GoRouter.refreshListenable] whenever settings change.
class _SettingsRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
