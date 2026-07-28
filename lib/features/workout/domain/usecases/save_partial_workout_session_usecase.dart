import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

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
  /// Expects session metrics [startTime], [samples], [sensorLocationIndex],
  /// [macAddress], [name], [avgBpm], and [maxBpm].
  ///
  /// Pass [existingId] (the id returned by a previous call to this use case
  /// for the same session) so this checkpoint updates that row in place.
  /// Returns a [Future] completing with the row's database ID — callers MUST store it
  /// and pass it back into subsequent calls.
  Future<int> call({
    required DateTime startTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
    int? existingId,
  }) => _repository.saveWorkoutCheckpoint(
    startTime: startTime,
    samples: samples,
    sensorLocationIndex: sensorLocationIndex,
    macAddress: macAddress,
    name: name,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    existingId: existingId,
  );
}

/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
SavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase(Ref ref) {
  return SavePartialWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}
