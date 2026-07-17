import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'save_device_profile_usecase.g.dart';

/// Encapsulates the application logic for caching a BLE sensor profile.
///
/// The [HrMonitorNotifier] in the presentation layer depends on this Use Case
/// instead of reaching into the infrastructure layer directly.
class SaveDeviceProfileUseCase {
  final WorkoutPersistenceRepository _repository;

  SaveDeviceProfileUseCase(this._repository);

  Future<void> call({
    required String macAddress,
    required String name,
    required int sensorLocationIndex,
  }) => _repository.saveDeviceProfile(
    macAddress: macAddress,
    name: name,
    sensorLocationIndex: sensorLocationIndex,
  );
}

@riverpod
SaveDeviceProfileUseCase saveDeviceProfileUseCase(Ref ref) {
  return SaveDeviceProfileUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}
