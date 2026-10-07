import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

/// Recovers workout sessions left unclosed by a crash or kill.
///
/// Finalizes records carrying heart rate samples by estimating `endTime`
/// from the sample count (one sample per second) and deletes empty
/// orphaned records. Returns the number of handled records, rethrowing
/// recovery failures after logging so startup can report them.
class SanitizeCrashedSessionsUseCase {
  final WorkoutPersistenceRepository _repository;

  SanitizeCrashedSessionsUseCase(this._repository);

  /// Scans persistent storage for crashed sessions and recovers them.
  ///
  /// Returns the number of finalized or deleted records.
  Future<int> call() async {
    try {
      final unclosed = await _repository.findUnclosedSessions();
      if (unclosed.isEmpty) return 0;

      log.i(
        '[SanitizeCrashedSessionsUseCase] Found ${unclosed.length} crashed/unclosed workout sessions to sanitize.',
      );

      for (final session in unclosed) {
        await _recover(session);
      }
      return unclosed.length;
    } on Object catch (e, st) {
      log.e(
        '[SanitizeCrashedSessionsUseCase] Error during crash recovery',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> _recover(WorkoutSession session) async {
    if (session.bpmSamples.isEmpty) {
      await _repository.deleteWorkoutSession(session.id);
      log.d(
        '[SanitizeCrashedSessionsUseCase] Deleted empty crashed session #${session.id}',
      );
      return;
    }
    final endTime = session.startTime
        .add(Duration(seconds: session.bpmSamples.length))
        .toUtc();
    // Recompute aggregates from the surviving samples: checkpoint values may
    // cover only a partial window and must not leak into the finalized record.
    var sum = 0;
    var maxBpm = 0;
    for (final sample in session.bpmSamples) {
      sum += sample;
      if (sample > maxBpm) maxBpm = sample;
    }
    final avgBpm = (sum / session.bpmSamples.length).round();
    await _repository.saveWorkoutSession(
      startTime: session.startTime,
      endTime: endTime,
      samples: session.bpmSamples,
      sensorLocationIndex: session.sensorLocationIndex,
      macAddress: session.deviceMacAddress,
      name: session.deviceName,
      avgBpm: avgBpm,
      maxBpm: maxBpm,
      existingId: session.id,
    );
    log.i(
      '[SanitizeCrashedSessionsUseCase] Sanitized crashed session #${session.id} with estimated endTime ($endTime).',
    );
  }
}
