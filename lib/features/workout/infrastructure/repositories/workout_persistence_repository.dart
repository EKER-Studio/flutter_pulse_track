import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/infrastructure/storage/isar_provider.dart';
import '../models/device_profile_dto.dart';
import '../models/workout_session_dto.dart';

part 'workout_persistence_repository.g.dart';

/// Repository abstracting local Isar database persistence for BLE sensor profiles
/// and immutable workout sessions.
class WorkoutPersistenceRepository {
  final Isar _isar;

  const WorkoutPersistenceRepository(this._isar);

  /// Caches the BLE sensor profile to the database.
  ///
  /// Uses an upsert-by-MAC semantic via the `replace: true` index in Isar.
  /// This ensures we only keep the freshest profile (e.g. updated name or 
  /// battery location) for a given physical sensor.
  Future<void> saveDeviceProfile({
    required String macAddress,
    required String name,
    required int sensorLocationIndex,
  }) async {
    final profile = DeviceProfileDto()
      ..macAddress = macAddress
      ..name = name
      ..lastSensorLocationIndex = sensorLocationIndex
      ..lastConnectedAt = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      await _isar.deviceProfileDtos.put(profile);
    });
  }

  /// Persists an immutable workout session after the BLE connection is closed.
  ///
  /// Computes the `avgBpm` and `maxBpm` from the raw telemetry [samples] before
  /// performing an atomic write transaction. Empty sessions (0 samples) are
  /// silently discarded to avoid cluttering the history view.
  Future<void> saveWorkoutSession({
    required DateTime startTime,
    required DateTime endTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
  }) async {
    if (samples.isEmpty) return;

    final maxBpm = samples.reduce(max);
    final avgBpm = (samples.reduce((a, b) => a + b) / samples.length).round();

    final session = WorkoutSessionDto()
      ..startTime = startTime.toUtc()
      ..endTime = endTime.toUtc()
      ..avgBpm = avgBpm
      ..maxBpm = maxBpm
      ..bpmSamples = samples
      ..sensorLocationIndex = sensorLocationIndex
      ..deviceMacAddress = macAddress
      ..deviceName = name;

    await _isar.writeTxn(() async {
      await _isar.workoutSessionDtos.put(session);
    });
  }
}

@riverpod
WorkoutPersistenceRepository workoutPersistenceRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return WorkoutPersistenceRepository(isar);
}
