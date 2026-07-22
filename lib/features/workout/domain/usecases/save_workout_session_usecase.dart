import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'save_workout_session_usecase.g.dart';

/// Encapsulates the application logic for persisting a completed workout session.
///
/// Invoked when a workout ends (user-initiated stop or connection loss). Writes
/// the full BPM sample trace, timing metadata, and device identifier into local
/// storage as an immutable record for historical replay and analytics.
class SaveWorkoutSessionUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  SaveWorkoutSessionUseCase(this._repository);

  /// Persists a workout session snapshot to local storage.
  ///
  /// The [startTime] and [endTime] delimit the session window. The [samples] list
  /// contains chronologically ordered BPM readings captured during the session.
  /// The [sensorLocationIndex], [macAddress], and [name] are captured from the
  /// connected sensor at session start and stored alongside the samples to ensure
  /// the record remains self-contained even if the device profile is later deleted.
  ///
  /// Pass [existingId] (the id returned by the session's last checkpoint call,
  /// if any) so this final write updates that same row instead of leaving it
  /// behind as an orphaned duplicate.
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

/// Riverpod provider that supplies a [SaveWorkoutSessionUseCase] wired to the
/// concrete [WorkoutPersistenceRepository] implementation.
@riverpod
SaveWorkoutSessionUseCase saveWorkoutSessionUseCase(Ref ref) {
  return SaveWorkoutSessionUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}
