import 'package:isar_community/isar.dart';

import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart'
    as domain;
import 'package:pulse_track/features/workout/infrastructure/models/device_profile_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/models/workout_session_dto.dart';

/// Concrete Isar-backed implementation of [WorkoutPersistenceRepository].
///
/// Repository abstracting local Isar database persistence for BLE sensor profiles
/// and immutable workout sessions.
class WorkoutPersistenceRepository
    implements domain.WorkoutPersistenceRepository {
  final Isar _isar;

  /// Creates a [WorkoutPersistenceRepository] instance backed by the given [_isar] database.
  const WorkoutPersistenceRepository(this._isar);

  /// Caches the BLE sensor profile to the database.
  ///
  /// Takes [macAddress], [name], and [sensorLocationIndex].
  /// Uses an upsert-by-MAC semantic via the `replace: true` index in Isar.
  /// Returns a [Future] completing when the device profile is written.
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
  /// Takes [startTime], [endTime], [samples], [sensorLocationIndex], [macAddress], [name],
  /// [avgBpm], [maxBpm], and optional [existingId].
  /// Empty sessions (0 samples) are silently discarded to avoid cluttering history.
  /// Returns a [Future] completing when the session is written.
  @override
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
  }) async {
    if (samples.isEmpty) return;

    final session = WorkoutSessionDto()
      ..id = existingId ?? Isar.autoIncrement
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

  /// Persists an in-progress workout session checkpoint.
  ///
  /// Takes [startTime], [samples], [sensorLocationIndex], [macAddress], [name],
  /// [avgBpm], [maxBpm], and optional [existingId].
  /// Returns a [Future] completing with the integer database ID assigned or updated.
  @override
  Future<int?> saveWorkoutCheckpoint({
    required DateTime startTime,
    required List<int> samples,
    required int sensorLocationIndex,
    required String macAddress,
    required String name,
    required int avgBpm,
    required int maxBpm,
    int? existingId,
  }) async {
    if (samples.isEmpty) return existingId;

    final session = WorkoutSessionDto()
      ..id = existingId ?? Isar.autoIncrement
      ..startTime = startTime.toUtc()
      ..endTime = null
      ..avgBpm = avgBpm
      ..maxBpm = maxBpm
      ..bpmSamples = samples
      ..sensorLocationIndex = sensorLocationIndex
      ..deviceMacAddress = macAddress
      ..deviceName = name;

    return _isar.writeTxn(() async {
      return _isar.workoutSessionDtos.put(session);
    });
  }

  /// Reactively streams every saved [DeviceProfileDto], mapped to domain [DeviceProfile],
  /// most-recently connected first whenever database changes occur.
  @override
  Stream<List<DeviceProfile>> watchSavedDeviceProfiles() {
    return _isar.deviceProfileDtos
        .where()
        .sortByLastConnectedAtDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map(_deviceProfileFromDto).toList());
  }

  /// Reactively streams every persisted [WorkoutSessionDto], mapped to domain [WorkoutSession],
  /// most recent first whenever database changes occur.
  @override
  Stream<List<WorkoutSession>> watchWorkoutHistory() {
    return _isar.workoutSessionDtos
        .where()
        .sortByStartTimeDesc()
        .watch(fireImmediately: true)
        .map((dtos) => dtos.map(_workoutSessionFromDto).toList());
  }

  /// Permanently deletes the workout session identified by [sessionId].
  ///
  /// Returns a [Future] completing when the deletion transaction is committed.
  @override
  Future<void> deleteWorkoutSession(int sessionId) async {
    await _isar.writeTxn(() async {
      await _isar.workoutSessionDtos.delete(sessionId);
    });
  }

  /// Permanently deletes all workout sessions identified by [sessionIds] in a single transaction.
  Future<void> deleteWorkoutSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return;
    await _isar.writeTxn(() async {
      for (final id in sessionIds) {
        await _isar.workoutSessionDtos.delete(id);
      }
    });
  }

  /// Persists multiple workout sessions in a single transaction.
  Future<void> saveWorkoutSessionsBatch(List<WorkoutSession> sessions) async {
    if (sessions.isEmpty) return;
    await _isar.writeTxn(() async {
      for (final session in sessions) {
        final dto = WorkoutSessionDto()
          ..id = Isar.autoIncrement
          ..startTime = session.startTime.toUtc()
          ..endTime = session.endTime?.toUtc()
          ..avgBpm = session.avgBpm
          ..maxBpm = session.maxBpm
          ..bpmSamples = session.bpmSamples
          ..sensorLocationIndex = session.sensorLocationIndex
          ..deviceMacAddress = session.deviceMacAddress
          ..deviceName = session.deviceName;
        await _isar.workoutSessionDtos.put(dto);
      }
    });
  }

  /// Finds persisted workout sessions that were never closed (where [WorkoutSessionDto.endTime] is null).
  ///
  /// Used by crash recovery to finalize or discard orphaned records.
  /// Returns the unclosed sessions mapped to domain, most recent first.
  @override
  Future<List<WorkoutSession>> findUnclosedSessions() async {
    final dtos = await _isar.workoutSessionDtos
        .filter()
        .endTimeIsNull()
        .sortByStartTimeDesc()
        .findAll();
    return dtos.map(_workoutSessionFromDto).toList();
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
