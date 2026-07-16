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
  });
}
