import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/sanitize_crashed_sessions_usecase.dart';

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

WorkoutSession _crashedSession({
  int id = 1,
  List<int> samples = const [120, 125, 130],
  DateTime? startTime,
}) {
  return WorkoutSession(
    id: id,
    startTime: startTime ?? DateTime.utc(2025, 6, 1, 10),
    endTime: null,
    avgBpm: 125,
    maxBpm: 130,
    bpmSamples: samples,
    sensorLocationIndex: 1,
    deviceMacAddress: 'AA:BB:CC:DD:EE:01',
    deviceName: 'Sensor',
  );
}

void main() {
  late WorkoutPersistenceRepository repository;
  late SanitizeCrashedSessionsUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = SanitizeCrashedSessionsUseCase(repository);
    when(() => repository.findUnclosedSessions()).thenAnswer((_) async => []);
    when(() => repository.deleteWorkoutSession(any())).thenAnswer((_) async {});
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
    test('returns 0 when no crashed sessions exist', () async {
      expect(await useCase(), 0);
      verifyNever(() => repository.deleteWorkoutSession(any()));
      verifyNever(
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
      );
    });

    test('deletes empty crashed sessions', () async {
      when(() => repository.findUnclosedSessions())
          .thenAnswer((_) async => [_crashedSession(id: 7, samples: [])]);

      expect(await useCase(), 1);
      verify(() => repository.deleteWorkoutSession(7)).called(1);
    });

    test(
      'finalizes sessions by estimating endTime from sample count',
      () async {
        final start = DateTime.utc(2025, 6, 1, 10);
        when(() => repository.findUnclosedSessions()).thenAnswer(
          (_) async => [
            _crashedSession(id: 3, samples: [120, 125, 130], startTime: start),
          ],
        );

        expect(await useCase(), 1);
        verify(
          () => repository.saveWorkoutSession(
            startTime: start,
            endTime: start.add(const Duration(seconds: 3)),
            samples: [120, 125, 130],
            sensorLocationIndex: 1,
            macAddress: 'AA:BB:CC:DD:EE:01',
            name: 'Sensor',
            avgBpm: 125,
            maxBpm: 130,
            existingId: 3,
          ),
        ).called(1);
        verifyNever(() => repository.deleteWorkoutSession(any()));
      },
    );

    test('handles a mixed batch of empty and sampled sessions', () async {
      final start = DateTime.utc(2025, 6, 1, 10);
      when(() => repository.findUnclosedSessions()).thenAnswer(
        (_) async => [
          _crashedSession(samples: []),
          _crashedSession(id: 2, samples: [100, 110], startTime: start),
        ],
      );

      expect(await useCase(), 2);
      verify(() => repository.deleteWorkoutSession(1)).called(1);
      verify(
        () => repository.saveWorkoutSession(
          startTime: start,
          endTime: start.add(const Duration(seconds: 2)),
          samples: [100, 110],
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: 2,
        ),
      ).called(1);
    });

    test('rethrows when the repository fails', () async {
      when(() => repository.findUnclosedSessions())
          .thenThrow(Exception('DB gone'));

      await expectLater(useCase(), throwsException);
    });
  });
}
