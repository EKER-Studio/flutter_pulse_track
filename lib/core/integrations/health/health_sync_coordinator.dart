import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

/// Summary statistics emitted upon successful completion of a health sync cycle.
class HealthSyncResult {
  /// The UTC timestamp when synchronization completed.
  final DateTime syncTimestamp;

  /// Number of entries fetched from the remote health store.
  final int remoteCount;

  /// Number of local sessions exported to the remote health store.
  final int pushedLocalCount;

  const HealthSyncResult({
    required this.syncTimestamp,
    required this.remoteCount,
    required this.pushedLocalCount,
  });
}

/// Coordinates synchronization between local workout persistence and platform health stores.
class HealthSyncCoordinator {
  /// Underlying health service abstraction.
  final HealthService healthService;

  /// Local workout persistence repository.
  final WorkoutPersistenceRepository repository;

  const HealthSyncCoordinator({
    required this.healthService,
    required this.repository,
  });

  /// Synchronizes workout sessions between local persistence and the platform health store.
  ///
  /// Deduplicates against existing remote records using a 60-second start time tolerance.
  ///
  /// @param startDate Optional query window start override.
  /// @param lastSyncTime Optional timestamp of previous sync to calculate overlap window.
  Future<HealthSyncResult?> sync({
    DateTime? startDate,
    DateTime? lastSyncTime,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final end = now;
      final start =
          startDate ??
          (lastSyncTime?.subtract(const Duration(days: 1)) ??
              now.subtract(const Duration(days: 30)));

      final remoteWorkouts = await healthService.fetchWorkoutHistory(
        start: start,
        end: end,
      );

      final localSessions = await repository.watchWorkoutHistory().first;
      final targetSessions = localSessions
          .where(
            (s) =>
                s.startTime.isAfter(start) &&
                s.startTime.isBefore(end) &&
                s.endTime != null &&
                s.bpmSamples.isNotEmpty,
          )
          .toList();

      final missingRemoteSessions = targetSessions.where((local) {
        final lUtc = local.startTime.toUtc();
        return !remoteWorkouts.any((remote) {
          final rUtc = remote.dateFrom.toUtc();
          return rUtc.difference(lUtc).inSeconds.abs() <= 60;
        });
      }).toList();

      int exportedCount = 0;
      for (final session in missingRemoteSessions) {
        final success = await healthService.writeWorkoutSession(
          session: session,
        );
        if (success) {
          exportedCount++;
        }
      }

      log.i(
        '[HealthSyncCoordinator] Health sync completed: remoteCount=${remoteWorkouts.length}, exportedCount=$exportedCount',
      );

      return HealthSyncResult(
        syncTimestamp: DateTime.now().toUtc(),
        remoteCount: remoteWorkouts.length,
        pushedLocalCount: exportedCount,
      );
    } on Object catch (e, stack) {
      log.e(
        '[HealthSyncCoordinator] Health sync failure',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Exports an individual workout session directly to the health platform.
  ///
  /// @param session Workout session to write.
  Future<bool> exportSession(WorkoutSession session) async {
    try {
      return await healthService.writeWorkoutSession(session: session);
    } on Object catch (e, stack) {
      log.e(
        '[HealthSyncCoordinator] exportSession failed',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
