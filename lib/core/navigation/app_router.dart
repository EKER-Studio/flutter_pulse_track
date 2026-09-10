import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/views/route_error_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_workout_history_usecase.dart';
import 'package:pulse_track/core/infrastructure/services/analytics_service.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';

part 'app_router.g.dart';

/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.
@riverpod
GoRouter appRouter(Ref ref) {
  final analyticsObserver = ref.watch(analyticsObserverProvider);

  return GoRouter(
    initialLocation: '/',
    observers: [?analyticsObserver],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        RouteErrorView(error: state.error),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const HrHomeView(),
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
    ],
  );
}

/// Fallback widget that loads a [WorkoutSession] from database by ID
/// when navigating via deep-link or cold boot where [GoRouterState.extra] is null.
class WorkoutDetailsLoaderView extends ConsumerWidget {
  /// Creates a [WorkoutDetailsLoaderView] for [sessionId].
  const WorkoutDetailsLoaderView({required this.sessionId, super.key});

  /// Database ID of the workout session to load.
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return historyAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
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
