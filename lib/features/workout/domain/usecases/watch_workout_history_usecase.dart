import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/models/workout_session.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'watch_workout_history_usecase.g.dart';

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
  Stream<List<WorkoutSession>> call() => _repository.watchWorkoutHistory();
}

/// Riverpod provider that supplies a [WatchWorkoutHistoryUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.
@riverpod
WatchWorkoutHistoryUseCase watchWorkoutHistoryUseCase(Ref ref) {
  return WatchWorkoutHistoryUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}

/// Reactive stream of workout history for direct use in
/// `ref.watch(watchWorkoutHistoryProvider)` from views.
@riverpod
Stream<List<WorkoutSession>> watchWorkoutHistoryStream(Ref ref) {
  return ref.watch(watchWorkoutHistoryUseCaseProvider).call();
}
