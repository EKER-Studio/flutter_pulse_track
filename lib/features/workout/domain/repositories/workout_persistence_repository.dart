import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Repository contract for persisting workout sessions and device profiles.
///
/// Placed in the domain layer so that presentation components (notifiers,
/// views) depend on this abstraction rather than on the concrete Isar-backed
/// implementation living in the infrastructure layer.
abstract class WorkoutPersistenceRepository {
  /// Caches or updates the BLE sensor profile.
  ///
  /// Takes [macAddress], [name], and [sensorLocationIndex].
  /// Returns a [Future] that completes when the device profile is saved.
  Future<void> saveDeviceProfile({
    required String macAddress,
    required String name,
    required int sensorLocationIndex,
  });

  /// Persists an immutable workout session after the BLE connection is closed.
  ///
  /// Expects session parameters [startTime], [endTime], [samples], [sensorLocationIndex],
  /// [macAddress], [name], [avgBpm], and [maxBpm].
  ///
  /// If [existingId] is provided (typically the id returned by the last
  /// checkpoint call for this session), the existing record is updated in place
  /// instead of inserting a new row.
  /// Returns a [Future] that completes when the session is written to persistent storage.
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

  /// Reactively streams saved sensor [DeviceProfile] items.
  ///
  /// Emits a list of device profiles ordered by most-recently connected first
  /// whenever local storage changes.
  Stream<List<DeviceProfile>> watchSavedDeviceProfiles();

  /// Reactively streams persisted [WorkoutSession] items.
  ///
  /// Emits a list of workout sessions ordered by most recent first whenever
  /// session records are inserted, modified, or deleted.
  Stream<List<WorkoutSession>> watchWorkoutHistory();

  /// Persists an in-progress workout session checkpoint.
  ///
  /// Requires session metrics [startTime], [samples], [sensorLocationIndex],
  /// [macAddress], [name], [avgBpm], and [maxBpm].
  ///
  /// If [existingId] is provided, updates that existing row in place.
  /// Returns a [Future] completing with the integer database ID assigned or updated
  /// for this session.
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
  ///
  /// Returns a [Future] that completes once the record is deleted.
  Future<void> deleteWorkoutSession(int sessionId);

  /// Scans persistent storage for crashed/unclosed workout sessions (where `endTime` is null).
  ///
  /// Finalizes incomplete records by assigning an estimated `endTime` derived from
  /// recorded heart rate samples or deletes empty orphaned records.
  Future<void> sanitizeCrashedSessions();
}
