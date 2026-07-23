import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

void main() {
  late WorkoutPersistenceRepository repository;

  setUp(() {
    repository = _MockRepository();
  });

  group('WorkoutPersistenceRepository contract', () {
    test('mock is a subtype of WorkoutPersistenceRepository', () {
      expect(repository, isA<WorkoutPersistenceRepository>());
    });

    test('saveDeviceProfile accepts all parameters', () async {
      when(
        () => repository.saveDeviceProfile(
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveDeviceProfile(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        sensorLocationIndex: 2,
      );

      verify(
        () => repository.saveDeviceProfile(
          macAddress: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          sensorLocationIndex: 2,
        ),
      ).called(1);
    });

    test('saveWorkoutSession accepts all parameters', () async {
      when(
        () => repository.saveWorkoutSession(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveWorkoutSession(
        startTime: DateTime(2026, 7, 23, 14, 0, 0),
        endTime: DateTime(2026, 7, 23, 15, 30, 0),
        samples: [60, 72, 88],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        avgBpm: 73,
        maxBpm: 88,
      );

      verify(
        () => repository.saveWorkoutSession(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });

    test('saveWorkoutSession accepts existingId', () async {
      when(
        () => repository.saveWorkoutSession(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveWorkoutSession(
        startTime: DateTime(2026, 1, 1),
        endTime: DateTime(2026, 1, 1, 1),
        samples: [60],
        sensorLocationIndex: 0,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Test',
        avgBpm: 60,
        maxBpm: 60,
        existingId: 42,
      );

      verify(
        () => repository.saveWorkoutSession(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: 42,
        ),
      ).called(1);
    });

    test('watchSavedDeviceProfiles returns Stream<List<DeviceProfile>>', () {
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => const Stream.empty());

      final result = repository.watchSavedDeviceProfiles();

      expect(result, isA<Stream<List<DeviceProfile>>>());
    });

    test('watchWorkoutHistory returns Stream<List<WorkoutSession>>', () {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => const Stream.empty());

      final result = repository.watchWorkoutHistory();

      expect(result, isA<Stream<List<WorkoutSession>>>());
    });

    test('saveWorkoutCheckpoint accepts all parameters and returns Future<int>',
        () async {
      when(
        () => repository.saveWorkoutCheckpoint(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) async => 7);

      final id = await repository.saveWorkoutCheckpoint(
        startTime: DateTime(2026, 1, 1),
        samples: [60],
        sensorLocationIndex: 0,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Test',
        avgBpm: 60,
        maxBpm: 60,
      );

      expect(id, 7);
    });

    test('saveWorkoutCheckpoint accepts existingId', () async {
      when(
        () => repository.saveWorkoutCheckpoint(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) async => 15);

      final id = await repository.saveWorkoutCheckpoint(
        startTime: DateTime(2026, 1, 1),
        samples: [72, 80],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Test',
        avgBpm: 76,
        maxBpm: 80,
        existingId: 3,
      );

      expect(id, 15);
    });

    test('deleteWorkoutSession accepts sessionId', () async {
      when(() => repository.deleteWorkoutSession(any()))
          .thenAnswer((_) async {});

      await repository.deleteWorkoutSession(42);

      verify(() => repository.deleteWorkoutSession(42)).called(1);
    });
  });
}