import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/presentation/views/route_error_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';

part 'app_router.g.dart';

/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
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
            path: 'details',
            name: 'workoutDetails',
            builder: (BuildContext context, GoRouterState state) {
              final extra = state.extra;
              if (extra is WorkoutSession) {
                return WorkoutDetailsView(session: extra);
              }
              // If deep-linked directly without session extra payload, fallback to error view
              return const RouteErrorView();
            },
          ),
        ],
      ),
    ],
  );
}
