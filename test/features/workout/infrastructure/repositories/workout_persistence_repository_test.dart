import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/infrastructure/models/device_profile_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/models/workout_session_dto.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart';

void main() {
  late Isar isar;
  late WorkoutPersistenceRepository repository;
  late Directory tmpDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('isar_test_');
    isar = await Isar.open([
      DeviceProfileDtoSchema,
      WorkoutSessionDtoSchema,
    ], directory: tmpDir.path);
    repository = WorkoutPersistenceRepository(isar);
  });

  tearDown(() async {
    await isar.close();
    tmpDir.deleteSync(recursive: true);
  });

  group('saveDeviceProfile', () {
    test('inserts a new device profile', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      final profiles = await isar.deviceProfileDtos.where().findAll();
      expect(profiles, hasLength(1));
      expect(profiles[0].macAddress, 'AA:BB:CC:DD:EE:01');
      expect(profiles[0].name, 'Polar H10');
      expect(profiles[0].lastSensorLocationIndex, 1);
    });

    test('upserts by macAddress when saving the same device twice', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10 (updated)',
        sensorLocationIndex: 2,
      );

      final profiles = await isar.deviceProfileDtos.where().findAll();
      expect(profiles, hasLength(1));
      expect(profiles[0].name, 'Polar H10 (updated)');
      expect(profiles[0].lastSensorLocationIndex, 2);
    });

    test('stores separate profiles for different mac addresses', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Sensor A',
        sensorLocationIndex: 1,
      );
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:02',
        name: 'Sensor B',
        sensorLocationIndex: 2,
      );

      final profiles = await isar.deviceProfileDtos.where().findAll();
      expect(profiles, hasLength(2));
    });

    test('sets lastConnectedAt close to now', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      final profiles = await isar.deviceProfileDtos.where().findAll();
      expect(
        profiles[0].lastConnectedAt
            .difference(DateTime.now().toUtc())
            .inSeconds
            .abs(),
        lessThan(2),
      );
    });
  });

  group('saveWorkoutSession', () {
    final startTime = DateTime(2025, 6, 1, 10);
    final endTime = DateTime(2025, 6, 1, 10, 30);

    test('inserts a new workout session', () async {
      await repository.saveWorkoutSession(
        startTime: startTime,
        endTime: endTime,
        samples: [72, 75, 80, 85, 90],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 80,
        maxBpm: 90,
      );

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, hasLength(1));
      expect(sessions[0].avgBpm, 80);
      expect(sessions[0].maxBpm, 90);
      expect(sessions[0].bpmSamples, [72, 75, 80, 85, 90]);
      expect(sessions[0].deviceMacAddress, 'AA:BB:CC:DD:EE:01');
      expect(sessions[0].deviceName, 'Polar H10');
    });

    test('skips empty samples silently', () async {
      await repository.saveWorkoutSession(
        startTime: startTime,
        endTime: endTime,
        samples: [],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 0,
        maxBpm: 0,
      );

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, isEmpty);
    });

    test('updates existing session when existingId is provided', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [72, 75],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 73,
        maxBpm: 75,
      );

      await repository.saveWorkoutSession(
        startTime: startTime,
        endTime: endTime,
        samples: [72, 75, 80, 85],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 78,
        maxBpm: 85,
        existingId: id,
      );

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, hasLength(1));
      expect(sessions[0].id, id);
      expect(sessions[0].avgBpm, 78);
      expect(sessions[0].bpmSamples, [72, 75, 80, 85]);
      expect(sessions[0].endTime, isNotNull);
    });
  });

  group('saveWorkoutCheckpoint', () {
    final startTime = DateTime(2025, 6, 1, 10);

    test('inserts a new checkpoint with null endTime', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
      );

      expect(id, greaterThan(0));

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, hasLength(1));
      expect(sessions[0].id, id);
      expect(sessions[0].endTime, isNull);
    });

    test('returns existingId when samples are empty', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 0,
        maxBpm: 0,
        existingId: 42,
      );

      expect(id, 42);
    });

    test('returns null when samples are empty and no existingId', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 0,
        maxBpm: 0,
      );

      expect(id, isNull);
    });

    test('updates existing checkpoint when existingId is provided', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [72],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 72,
        maxBpm: 72,
      );

      await repository.saveWorkoutCheckpoint(
        startTime: startTime,
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
        existingId: id,
      );

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, hasLength(1));
      expect(sessions[0].bpmSamples, [72, 75, 80]);
    });
  });

  group('watchSavedDeviceProfiles', () {
    test('fires immediately with current profiles', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      final result = await repository.watchSavedDeviceProfiles().first;

      expect(result, hasLength(1));
      expect(result[0].macAddress, 'AA:BB:CC:DD:EE:01');
    });

    test('emits when a new profile is saved', () async {
      final future = repository.watchSavedDeviceProfiles().skip(1).first;

      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      final result = await future;
      expect(result, hasLength(1));
      expect(result[0].name, 'Polar H10');
    });

    test('returns profiles sorted by lastConnectedAt descending', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:02',
        name: 'Old Sensor',
        sensorLocationIndex: 1,
      );
      await Future.delayed(const Duration(milliseconds: 1));
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Recent Sensor',
        sensorLocationIndex: 2,
      );

      final result = await repository.watchSavedDeviceProfiles().first;

      expect(result, hasLength(2));
      expect(result[0].name, 'Recent Sensor');
      expect(result[1].name, 'Old Sensor');
    });

    test('maps DTOs to domain DeviceProfile', () async {
      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      final result = await repository.watchSavedDeviceProfiles().first;

      expect(result[0], isA<DeviceProfile>());
      expect(result[0].id, greaterThan(0));
      expect(result[0].lastSensorLocationIndex, 1);
    });
  });

  group('watchWorkoutHistory', () {
    final startTime1 = DateTime(2025, 6, 1, 10);
    final startTime2 = DateTime(2025, 6, 2, 10);

    test('fires immediately with current sessions', () async {
      await repository.saveWorkoutSession(
        startTime: startTime1,
        endTime: startTime1.add(const Duration(minutes: 30)),
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
      );

      final result = await repository.watchWorkoutHistory().first;

      expect(result, hasLength(1));
      expect(result[0].deviceName, 'Polar H10');
    });

    test('emits when a new session is saved', () async {
      final future = repository.watchWorkoutHistory().skip(1).first;

      await repository.saveWorkoutSession(
        startTime: startTime1,
        endTime: startTime1.add(const Duration(minutes: 30)),
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
      );

      final result = await future;
      expect(result, hasLength(1));
      expect(result[0].deviceName, 'Polar H10');
    });

    test('returns sessions sorted by startTime descending', () async {
      await repository.saveWorkoutSession(
        startTime: startTime1,
        endTime: startTime1.add(const Duration(minutes: 30)),
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Old Session',
        avgBpm: 76,
        maxBpm: 80,
      );
      await repository.saveWorkoutSession(
        startTime: startTime2,
        endTime: startTime2.add(const Duration(minutes: 20)),
        samples: [80, 85, 90],
        sensorLocationIndex: 2,
        macAddress: 'AA:BB:CC:DD:EE:02',
        name: 'Recent Session',
        avgBpm: 85,
        maxBpm: 90,
      );

      final result = await repository.watchWorkoutHistory().first;

      expect(result, hasLength(2));
      expect(result[0].deviceName, 'Recent Session');
      expect(result[1].deviceName, 'Old Session');
    });

    test('returns empty list when no sessions exist', () async {
      final result = await repository.watchWorkoutHistory().first;
      expect(result, isEmpty);
    });

    test('maps DTOs to domain WorkoutSession', () async {
      await repository.saveWorkoutSession(
        startTime: startTime1,
        endTime: startTime1.add(const Duration(minutes: 30)),
        samples: [72, 75, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
      );

      final result = await repository.watchWorkoutHistory().first;

      expect(result[0], isA<WorkoutSession>());
      expect(result[0].bpmSamples, [72, 75, 80]);
      expect(result[0].endTime, isNotNull);
    });
  });

  group('deleteWorkoutSession', () {
    test('deletes an existing session', () async {
      final id = await repository.saveWorkoutCheckpoint(
        startTime: DateTime(2025, 6, 1, 10),
        samples: [72, 75],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 73,
        maxBpm: 75,
      );

      await repository.deleteWorkoutSession(id!);

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, isEmpty);
    });

    test('does nothing when session does not exist', () async {
      await repository.deleteWorkoutSession(999);

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, isEmpty);
    });

    test('does not affect other sessions', () async {
      await repository.saveWorkoutSession(
        startTime: DateTime(2025, 6, 1, 10),
        endTime: DateTime(2025, 6, 1, 10, 30),
        samples: [72, 75],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        avgBpm: 73,
        maxBpm: 75,
      );
      final id2 = await repository.saveWorkoutCheckpoint(
        startTime: DateTime(2025, 6, 2, 10),
        samples: [80, 85],
        sensorLocationIndex: 2,
        macAddress: 'AA:BB:CC:DD:EE:02',
        name: 'Sensor B',
        avgBpm: 82,
        maxBpm: 85,
      );

      await repository.deleteWorkoutSession(id2!);

      final sessions = await isar.workoutSessionDtos.where().findAll();
      expect(sessions, hasLength(1));
    });
  });

  group('findUnclosedSessions', () {
    test('returns empty when all sessions are closed', () async {
      final dto = WorkoutSessionDto()
        ..startTime = DateTime(2025, 6, 1, 10).toUtc()
        ..endTime = DateTime(2025, 6, 1, 10, 30).toUtc()
        ..bpmSamples = [120]
        ..avgBpm = 120
        ..maxBpm = 120
        ..sensorLocationIndex = 1
        ..deviceMacAddress = 'AA:BB:CC:DD:EE:01'
        ..deviceName = 'Sensor';

      await isar.writeTxn(() => isar.workoutSessionDtos.put(dto));

      expect(await repository.findUnclosedSessions(), isEmpty);
    });

    test('returns only sessions with null endTime', () async {
      final closed = WorkoutSessionDto()
        ..startTime = DateTime(2025, 6, 1, 10).toUtc()
        ..endTime = DateTime(2025, 6, 1, 10, 30).toUtc()
        ..bpmSamples = [120]
        ..avgBpm = 120
        ..maxBpm = 120
        ..sensorLocationIndex = 1
        ..deviceMacAddress = 'AA:BB:CC:DD:EE:01'
        ..deviceName = 'Sensor';
      final crashed = WorkoutSessionDto()
        ..startTime = DateTime(2025, 6, 2, 10).toUtc()
        ..endTime = null
        ..bpmSamples = [120, 125]
        ..avgBpm = 122
        ..maxBpm = 125
        ..sensorLocationIndex = 1
        ..deviceMacAddress = 'AA:BB:CC:DD:EE:01'
        ..deviceName = 'Sensor';

      await isar.writeTxn(() async {
        await isar.workoutSessionDtos.put(closed);
        await isar.workoutSessionDtos.put(crashed);
      });

      final unclosed = await repository.findUnclosedSessions();
      expect(unclosed, hasLength(1));
      expect(unclosed.first.endTime, isNull);
      expect(unclosed.first.bpmSamples, [120, 125]);
    });
  });

  group('workoutPersistenceRepositoryProvider', () {
    test('throws when not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(workoutPersistenceRepositoryProvider),
        throwsA(
          predicate(
            (e) => e.toString().contains('isarProvider'),
            'throws with missing isarProvider override',
          ),
        ),
      );
    });

    test('resolves the overridden concrete instance', () {
      final concrete = WorkoutPersistenceRepository(isar);
      final container = ProviderContainer(
        overrides: [
          workoutPersistenceRepositoryProvider.overrideWithValue(concrete),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(workoutPersistenceRepositoryProvider);
      expect(repo, same(concrete));
    });
  });
}
