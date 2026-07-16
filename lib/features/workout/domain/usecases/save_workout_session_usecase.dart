import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/workout_persistence_repository.dart';
import '../../infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'save_workout_session_usecase.g.dart';

/// Encapsulates the application logic for persisting a completed workout session.
///
/// The [HrMonitorNotifier] in the presentation layer depends on this Use Case
/// instead of reaching into the infrastructure layer directly.
class SaveWorkoutSessionUseCase {
  final WorkoutPersistenceRepository _repository;

  SaveWorkoutSessionUseCase(this._repository);

  Future<void> call({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
  }) =>
      _repository.saveWorkoutSession(
        startTime: startTime,
        endTime: endTime,
        samples: samples,
        sensorLocationIndex: sensorLocationIndex,
        macAddress: macAddress,
        name: name,
      );
}

@riverpod
SaveWorkoutSessionUseCase saveWorkoutSessionUseCase(Ref ref) {
  return SaveWorkoutSessionUseCase(ref.watch(impl.workoutPersistenceRepositoryProvider));
}
