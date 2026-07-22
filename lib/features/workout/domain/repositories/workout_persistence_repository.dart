import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

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
  ///
  /// If [existingId] is provided (typically the id returned by the last
  /// [saveWorkoutCheckpoint] call for this session), the existing row is
  /// updated in place instead of inserting a new one — otherwise the final
  /// save would leave every prior checkpoint row orphaned in the database.
  Future<void> saveWorkoutSession({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
    int? existingId,
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
  ///
  /// If [existingId] is provided (the id returned by a previous checkpoint
  /// call for this same session), the existing row is updated in place.
  /// Otherwise a new row is inserted and its id is returned — callers MUST
  /// pass that id back into subsequent checkpoint calls (and into the final
  /// [saveWorkoutSession] call) or every checkpoint will insert a brand new
  /// duplicate row instead of updating one.
  Future<int> saveWorkoutCheckpoint({
    required DateTime startTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
    int? existingId,
  });

  /// Permanently deletes the workout session identified by [sessionId].
  Future<void> deleteWorkoutSession(int sessionId);
}
