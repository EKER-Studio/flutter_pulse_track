import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/delete_workout_session_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late DeleteWorkoutSessionUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = DeleteWorkoutSessionUseCase(repository);
    when(
      () => repository.deleteWorkoutSession(any()),
    ).thenAnswer((_) async {});
  });

  group('call', () {
    test('delegates to repository.deleteWorkoutSession', () async {
      await useCase(1);

      verify(() => repository.deleteWorkoutSession(1)).called(1);
    });

    test('forwards the sessionId argument', () async {
      await useCase(42);

      verify(() => repository.deleteWorkoutSession(42)).called(1);
    });

    test('accepts zero as sessionId', () async {
      await useCase(0);

      verify(() => repository.deleteWorkoutSession(0)).called(1);
    });

    test('accepts negative sessionId', () async {
      await useCase(-1);

      verify(() => repository.deleteWorkoutSession(-1)).called(1);
    });

    test('accepts large sessionId', () async {
      await useCase(999999);

      verify(() => repository.deleteWorkoutSession(999999)).called(1);
    });

    test('propagates repository exceptions', () async {
      when(
        () => repository.deleteWorkoutSession(any()),
      ).thenThrow(Exception('Delete failed'));

      expect(
        () => useCase(1),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Delete failed'),
        )),
      );
    });
  });
}