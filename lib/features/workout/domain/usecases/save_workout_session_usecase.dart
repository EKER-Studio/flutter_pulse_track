import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

/// Encapsulates the application logic for persisting a completed workout session.
///
/// Invoked when a workout ends (user-initiated stop or connection loss). Writes
/// the full BPM sample trace, timing metadata, and device identifier into local
/// storage as an immutable record for historical replay and analytics.
class SaveWorkoutSessionUseCase {
  final WorkoutPersistenceRepository _repository;

  SaveWorkoutSessionUseCase(this._repository);

  /// Persists a workout session snapshot to local storage.
  ///
  /// Takes session boundaries [startTime] and [endTime], [samples] list of BPM values,
  /// [sensorLocationIndex], device identifier [macAddress], device [name],
  /// session metrics [avgBpm] and [maxBpm], and optional [existingId].
  ///
  /// Pass [existingId] (the id returned by the session's last checkpoint call,
  /// if any) so this final write updates that same row instead of leaving an orphaned duplicate.
  /// Returns a [Future] that completes when the session is successfully written.
  Future<void> call({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
    int? existingId,
  }) => _repository.saveWorkoutSession(
    startTime: startTime,
    endTime: endTime,
    samples: samples,
    sensorLocationIndex: sensorLocationIndex,
    macAddress: macAddress,
    name: name,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    existingId: existingId,
  );
}
