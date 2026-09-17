import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late SavePartialWorkoutSessionUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = SavePartialWorkoutSessionUseCase(repository);
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
    ).thenAnswer((_) async => 1);
  });

  group('call', () {
    test('delegates to repository.saveWorkoutCheckpoint', () async {
      await useCase(
        startTime: DateTime(2026, 7, 23, 14, 30),
        samples: [72, 80],
        sensorLocationIndex: 2,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        avgBpm: 76,
        maxBpm: 80,
      );

      verify(
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
      ).called(1);
    });

    test('forwards all required parameters unchanged', () async {
      final start = DateTime(2026, 1, 15, 10);

      await useCase(
        startTime: start,
        samples: [60, 72, 88, 95],
        sensorLocationIndex: 1,
        macAddress: '11:22:33:44:55:66',
        name: 'Garmin HRM Pro',
        avgBpm: 79,
        maxBpm: 95,
      );

      verify(
        () => repository.saveWorkoutCheckpoint(
          startTime: start,
          samples: [60, 72, 88, 95],
          sensorLocationIndex: 1,
          macAddress: '11:22:33:44:55:66',
          name: 'Garmin HRM Pro',
          avgBpm: 79,
          maxBpm: 95,
        ),
      ).called(1);
    });

    test('returns the id from repository', () async {
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
      ).thenAnswer((_) async => 42);

      final id = await useCase(
        startTime: DateTime(2026),
        samples: [60],
        sensorLocationIndex: 0,
        macAddress: '00:00:00:00:00:00',
        name: 'Test',
        avgBpm: 60,
        maxBpm: 60,
      );

      expect(id, 42);
    });

    test('returns zero when repository returns zero', () async {
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
      ).thenAnswer((_) async => 0);

      final id = await useCase(
        startTime: DateTime(2026),
        samples: [72],
        sensorLocationIndex: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Device',
        avgBpm: 72,
        maxBpm: 72,
      );

      expect(id, 0);
    });

    test('passes existingId when provided', () async {
      await useCase(
        startTime: DateTime(2026),
        samples: [60],
        sensorLocationIndex: 0,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Test',
        avgBpm: 60,
        maxBpm: 60,
        existingId: 15,
      );

      verify(
        () => repository.saveWorkoutCheckpoint(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: 15,
        ),
      ).called(1);
    });

    test('propagates repository exceptions', () async {
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
      ).thenThrow(Exception('Checkpoint failed'));

      expect(
        () => useCase(
          startTime: DateTime(2026),
          samples: [60],
          sensorLocationIndex: 0,
          macAddress: 'AA:BB:CC:DD:EE:FF',
          name: 'Test',
          avgBpm: 60,
          maxBpm: 60,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Checkpoint failed'),
          ),
        ),
      );
    });
  });
}
