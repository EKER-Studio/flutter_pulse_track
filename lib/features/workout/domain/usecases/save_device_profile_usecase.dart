import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'save_device_profile_usecase.g.dart';

/// Encapsulates the application logic for caching a BLE sensor profile.
///
/// Invoked after a successful connection to persist the device's MAC address,
/// display name, and body sensor location into local storage. The underlying
/// repository uses an upsert strategy keyed by MAC address, so repeated calls
/// for the same device overwrite the existing profile in place.
class SaveDeviceProfileUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  SaveDeviceProfileUseCase(this._repository);

  /// Persists or updates the device profile for the sensor identified by [macAddress].
  ///
  /// The [name] reflects the device's broadcast display name. The
  /// [sensorLocationIndex] is the raw integer index of the [BodySensorLocation]
  /// enum, read from GATT characteristic 0x2A38.
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

/// Riverpod provider that supplies a [SaveDeviceProfileUseCase] wired to the
/// concrete [WorkoutPersistenceRepository] implementation.
@riverpod
SaveDeviceProfileUseCase saveDeviceProfileUseCase(Ref ref) {
  return SaveDeviceProfileUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}
