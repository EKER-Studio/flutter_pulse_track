import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_workout_history_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Helpers ────────────────────────────────────────────────────────────────

WorkoutSession _session({
  int id = 1,
  DateTime? startTime,
  DateTime? endTime,
  int avgBpm = 75,
  int maxBpm = 120,
  List<int> samples = const [60, 72, 88],
  int sensorLocationIndex = 0,
  String macAddress = 'AA:BB:CC:DD:EE:FF',
  String name = 'Polar H10',
}) {
  return WorkoutSession(
    id: id,
    startTime: startTime ?? DateTime(2026, 7, 23),
    endTime: endTime,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    bpmSamples: samples,
    sensorLocationIndex: sensorLocationIndex,
    deviceMacAddress: macAddress,
    deviceName: name,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late WatchWorkoutHistoryUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = WatchWorkoutHistoryUseCase(repository);
  });

  group('call', () {
    test('returns a Stream', () {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => const Stream.empty());

      expect(useCase.call(), isA<Stream<List<WorkoutSession>>>());
    });

    test('delegates to repository.watchWorkoutHistory', () {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => const Stream.empty());

      useCase.call();

      verify(() => repository.watchWorkoutHistory()).called(1);
    });

    test('returns the same stream instance from repository', () {
      final stream = Stream<List<WorkoutSession>>.empty();
      when(() => repository.watchWorkoutHistory()).thenAnswer((_) => stream);

      expect(useCase.call(), same(stream));
    });

    test('emits the list of sessions from repository', () {
      final sessions = [_session(id: 1), _session(id: 2)];
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => Stream.value(sessions));

      expect(
        useCase.call(),
        emits(sessions),
      );
    });

    test('emits multiple updates sequentially', () async {
      final controller = StreamController<List<WorkoutSession>>();
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => controller.stream);

      final first = [_session(id: 1)];
      final second = [_session(id: 1), _session(id: 2)];
      final future = expectLater(
        useCase.call(),
        emitsInOrder([first, second]),
      );

      controller.add(first);
      controller.add(second);
      await controller.close();
      await future;
    });

    test('emits empty list when repository emits empty list', () {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => Stream.value([]));

      expect(
        useCase.call(),
        emits(<WorkoutSession>[]),
      );
    });

    test('forwards repository errors on the stream', () async {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => Stream.error(Exception('DB error')));

      expect(
        useCase.call(),
        emitsError(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('DB error'),
        )),
      );
    });

    test('completes when repository stream completes', () async {
      when(() => repository.watchWorkoutHistory())
          .thenAnswer((_) => const Stream.empty());

      await expectLater(useCase.call(), emitsDone);
    });
  });
}