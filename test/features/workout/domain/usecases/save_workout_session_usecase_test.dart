import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Factory helpers ─────────────────────────────────────────────────────────

Future<void> _callUseCase(
  SaveWorkoutSessionUseCase useCase, {
  DateTime? startTime,
  DateTime? endTime,
  List<int> samples = const [],
  int sensorLocationIndex = 0,
  String macAddress = '00:11:22:33:44:55',
  String name = 'Test HR',
  int avgBpm = 75,
  int maxBpm = 120,
  int? existingId,
}) {
  return useCase(
    startTime: startTime ?? DateTime(2026, 7, 23, 14, 30, 0),
    endTime: endTime ?? DateTime(2026, 7, 23, 15, 0, 0),
    samples: samples,
    sensorLocationIndex: sensorLocationIndex,
    macAddress: macAddress,
    name: name,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    existingId: existingId,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late SaveWorkoutSessionUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = SaveWorkoutSessionUseCase(repository);
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
  });

  group('call', () {
    test('delegates to repository.saveWorkoutSession', () async {
      await _callUseCase(useCase);

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

    test('forwards all required parameters unchanged', () async {
      final start = DateTime(2026, 1, 15, 10, 0, 0);
      final end = DateTime(2026, 1, 15, 11, 30, 0);

      await useCase(
        startTime: start,
        endTime: end,
        samples: [72, 80, 95, 110, 88],
        sensorLocationIndex: 2,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        avgBpm: 89,
        maxBpm: 110,
      );

      verify(
        () => repository.saveWorkoutSession(
          startTime: start,
          endTime: end,
          samples: [72, 80, 95, 110, 88],
          sensorLocationIndex: 2,
          macAddress: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          avgBpm: 89,
          maxBpm: 110,
          existingId: null,
        ),
      ).called(1);
    });

    test('passes existingId when provided', () async {
      await useCase(
        startTime: DateTime(2026, 1, 1, 0, 0, 0),
        endTime: DateTime(2026, 1, 1, 1, 0, 0),
        samples: [60],
        sensorLocationIndex: 0,
        macAddress: '00:11:22:33:44:55',
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

    

    test('propagates repository exceptions', () async {
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
      ).thenThrow(Exception('DB write failed'));

      expect(
        () => _callUseCase(useCase, samples: [60]),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('DB write failed'),
        )),
      );
    });

    test('works with empty samples list', () async {
      await useCase(
        startTime: DateTime(2026, 1, 1, 0, 0, 0),
        endTime: DateTime(2026, 1, 1, 0, 30, 0),
        samples: [],
        sensorLocationIndex: 1,
        macAddress: '11:22:33:44:55:66',
        name: 'Garmin HRM',
        avgBpm: 0,
        maxBpm: 0,
      );

      verify(
        () => repository.saveWorkoutSession(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: [],
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });
  });
}