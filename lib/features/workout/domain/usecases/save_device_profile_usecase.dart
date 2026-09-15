import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

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
  /// [sensorLocationIndex] is the raw integer index of the body sensor location enum,
  /// read from GATT characteristic 0x2A38.
  /// Returns a [Future] that completes when the profile is saved.
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
