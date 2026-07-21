import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'delete_workout_session_usecase.g.dart';

/// Encapsulates permanently deleting a persisted workout session.
///
/// This is the sole sanctioned way for the presentation layer to delete a
/// workout session — views must depend on this use case rather than
/// importing `isar_community` and calling `IsarCollection.delete` directly.
class DeleteWorkoutSessionUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  DeleteWorkoutSessionUseCase(this._repository);

  /// Permanently deletes the workout session identified by [sessionId].
  Future<void> call(int sessionId) =>
      _repository.deleteWorkoutSession(sessionId);
}

/// Riverpod provider that supplies a [DeleteWorkoutSessionUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.
@riverpod
DeleteWorkoutSessionUseCase deleteWorkoutSessionUseCase(Ref ref) {
  return DeleteWorkoutSessionUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}
