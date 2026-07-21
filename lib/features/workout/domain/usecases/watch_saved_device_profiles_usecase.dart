import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/models/device_profile.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as impl;

part 'watch_saved_device_profiles_usecase.g.dart';

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
  Stream<List<DeviceProfile>> call() => _repository.watchSavedDeviceProfiles();
}

/// Riverpod provider that supplies a [WatchSavedDeviceProfilesUseCase] wired
/// to the concrete [WorkoutPersistenceRepository] implementation.
@riverpod
WatchSavedDeviceProfilesUseCase watchSavedDeviceProfilesUseCase(Ref ref) {
  return WatchSavedDeviceProfilesUseCase(
    ref.watch(impl.workoutPersistenceRepositoryProvider),
  );
}

/// Reactive stream of saved device profiles for direct use in
/// `ref.watch(watchSavedDeviceProfilesProvider)` from views.
@riverpod
Stream<List<DeviceProfile>> watchSavedDeviceProfilesStream(Ref ref) {
  return ref.watch(watchSavedDeviceProfilesUseCaseProvider).call();
}
