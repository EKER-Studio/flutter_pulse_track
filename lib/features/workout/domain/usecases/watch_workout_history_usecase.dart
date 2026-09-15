import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

/// Encapsulates reactively observing the full workout session history.
///
/// This is the sole sanctioned way for the presentation layer to read
/// workout history — views must depend on this use case (via
/// [watchWorkoutHistoryProvider]) rather than importing `isar_community`
/// and querying `WorkoutSessionDto` directly.
class WatchWorkoutHistoryUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  WatchWorkoutHistoryUseCase(this._repository);

  /// Streams every persisted [WorkoutSession], most recent first.
  ///
  /// Emits a new list of workout sessions whenever records are inserted or removed.
  Stream<List<WorkoutSession>> call() => _repository.watchWorkoutHistory();
}
