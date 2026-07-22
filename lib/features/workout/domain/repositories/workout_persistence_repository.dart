import 'package:ble_heart_rate_monitor/features/workout/domain/models/device_profile.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/models/workout_session.dart';

/// Repository contract for persisting workout sessions and device profiles.
///
/// Placed in the domain layer so that presentation components (notifiers,
/// views) depend on this abstraction rather than on the concrete Isar-backed
/// implementation living in the infrastructure layer.
abstract class WorkoutPersistenceRepository {
  /// Caches or updates the BLE sensor profile.
  Future<void> saveDeviceProfile({
    required String macAddress,
    required String name,
    required int sensorLocationIndex,
  });

  /// Persists an immutable workout session after the BLE connection is closed.
  Future<void> saveWorkoutSession({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
  });

  /// Reactively streams every saved sensor [DeviceProfile], most-recently
  /// connected first.
  Stream<List<DeviceProfile>> watchSavedDeviceProfiles();

  /// Reactively streams every persisted [WorkoutSession], most recent first.
  Stream<List<WorkoutSession>> watchWorkoutHistory();

  /// Persists an in-progress workout session checkpoint.
  ///
  /// Unlike [saveWorkoutSession], the [endTime] is left as `null` so the
  /// record remains editable while the workout is still active. The [samples]
  /// list should contain all samples collected up to the moment this checkpoint
  /// is written.
  Future<void> saveWorkoutCheckpoint({
    required DateTime startTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
  });

  /// Permanently deletes the workout session identified by [sessionId].
  Future<void> deleteWorkoutSession(int sessionId);
}
