import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

/// Encapsulates reactively observing every saved BLE sensor profile.
///
/// This is the sole sanctioned way for the presentation layer to read saved
/// device profiles — views must depend on this use case (via
/// [watchSavedDeviceProfilesProvider]) rather than importing `isar_community`
/// and querying `DeviceProfileDto` directly.
class WatchSavedDeviceProfilesUseCase {
  final WorkoutPersistenceRepository _repository;

  /// Creates an instance backed by the given [_repository].
  WatchSavedDeviceProfilesUseCase(this._repository);

  /// Streams every saved [DeviceProfile], most-recently connected first.
  ///
  /// Emits a list of device profiles whenever persistent storage updates.
  Stream<List<DeviceProfile>> call() => _repository.watchSavedDeviceProfiles();
}
