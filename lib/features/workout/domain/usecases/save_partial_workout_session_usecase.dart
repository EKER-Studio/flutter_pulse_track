import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'save_partial_workout_session_usecase.g.dart';

/// Encapsulates the application logic for persisting a partial workout session
/// snapshot as a checkpoint during an active workout.
///
/// Invoked periodically (every 30–60 seconds) while a workout is in progress, or
/// when the app is about to be backgrounded/killed. The [endTime] is left `null`
/// so the record remains in an "active" state in the database, allowing the
/// final [SaveWorkoutSessionUseCase] call to complete the session with accurate
/// timing and a full sample list.
class SavePartialWorkoutSessionUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  SavePartialWorkoutSessionUseCase(this._repository);

  /// Persists a partial workout session snapshot to local storage.
  ///
  /// The [startTime] marks the session start and [endTime] is `null` to keep the
  /// record active. The [samples] list contains the accumulated BPM readings
  /// captured to date. The [sensorLocationIndex], [macAddress], and [name] are
  /// captured from the connected sensor at session start.
  Future<void> call({
    required DateTime startTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
  }) => _repository.saveWorkoutCheckpoint(
    startTime: startTime,
    samples: samples,
    sensorLocationIndex: sensorLocationIndex,
    macAddress: macAddress,
    name: name,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
  );
}

/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.
@riverpod
SavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase(Ref ref) {
  return SavePartialWorkoutSessionUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}
