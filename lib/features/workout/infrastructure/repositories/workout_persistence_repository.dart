import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/core/infrastructure/storage/isar_provider.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/models/device_profile.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/models/workout_session.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/repositories/workout_persistence_repository.dart'
    as domain;
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/models/device_profile_dto.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/models/workout_session_dto.dart';

part 'workout_persistence_repository.g.dart';

/// Concrete Isar-backed implementation of [WorkoutPersistenceRepository].
///
/// Repository abstracting local Isar database persistence for BLE sensor profiles
/// and immutable workout sessions.
class WorkoutPersistenceRepository
    implements domain.WorkoutPersistenceRepository {
  final Isar _isar;

  const WorkoutPersistenceRepository(this._isar);

  /// Caches the BLE sensor profile to the database.
  ///
  /// Uses an upsert-by-MAC semantic via the `replace: true` index in Isar.
  /// This ensures we only keep the freshest profile (e.g. updated name or
  /// battery location) for a given physical sensor.
  @override
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
  @override
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

  /// Reactively streams every saved [DeviceProfileDto], mapped to the
  /// domain-level [DeviceProfile], most-recently connected first.
  @override
  Stream<List<DeviceProfile>> watchSavedDeviceProfiles() {
    return _isar.deviceProfileDtos
        .where()
        .sortByLastConnectedAtDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map(_deviceProfileFromDto).toList());
  }

  /// Reactively streams every persisted [WorkoutSessionDto], mapped to the
  /// domain-level [WorkoutSession], most recent first.
  @override
  Stream<List<WorkoutSession>> watchWorkoutHistory() {
    return _isar.workoutSessionDtos
        .where()
        .sortByStartTimeDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map(_workoutSessionFromDto).toList());
  }

  /// Permanently deletes the workout session identified by [sessionId].
  @override
  Future<void> deleteWorkoutSession(int sessionId) async {
    await _isar.writeTxn(() async {
      await _isar.workoutSessionDtos.delete(sessionId);
    });
  }

  DeviceProfile _deviceProfileFromDto(DeviceProfileDto dto) => DeviceProfile(
    id: dto.id,
    macAddress: dto.macAddress,
    name: dto.name,
    lastConnectedAt: dto.lastConnectedAt,
    lastSensorLocationIndex: dto.lastSensorLocationIndex,
  );

  WorkoutSession _workoutSessionFromDto(WorkoutSessionDto dto) =>
      WorkoutSession(
        id: dto.id,
        startTime: dto.startTime,
        endTime: dto.endTime,
        avgBpm: dto.avgBpm,
        maxBpm: dto.maxBpm,
        bpmSamples: dto.bpmSamples,
        sensorLocationIndex: dto.sensorLocationIndex,
        deviceMacAddress: dto.deviceMacAddress,
        deviceName: dto.deviceName,
      );
}

@riverpod
WorkoutPersistenceRepository workoutPersistenceRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return WorkoutPersistenceRepository(isar);
}
