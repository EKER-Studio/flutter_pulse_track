import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_saved_device_profiles_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Helpers ────────────────────────────────────────────────────────────────

DeviceProfile _profile({
  int id = 1,
  String macAddress = 'AA:BB:CC:DD:EE:FF',
  String name = 'Polar H10',
  DateTime? lastConnectedAt,
  int lastSensorLocationIndex = 0,
}) {
  return DeviceProfile(
    id: id,
    macAddress: macAddress,
    name: name,
    lastConnectedAt: lastConnectedAt ?? DateTime(2026, 7, 23),
    lastSensorLocationIndex: lastSensorLocationIndex,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late WatchSavedDeviceProfilesUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = WatchSavedDeviceProfilesUseCase(repository);
  });

  group('call', () {
    test('returns a Stream', () {
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => const Stream.empty());

      expect(useCase.call(), isA<Stream<List<DeviceProfile>>>());
    });

    test('delegates to repository.watchSavedDeviceProfiles', () {
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => const Stream.empty());

      useCase.call();

      verify(() => repository.watchSavedDeviceProfiles()).called(1);
    });

    test('returns the same stream instance from repository', () {
      final stream = Stream<List<DeviceProfile>>.empty();
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => stream);

      expect(useCase.call(), same(stream));
    });

    test('emits the list of profiles from repository', () {
      final profiles = [_profile(id: 1), _profile(id: 2)];
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => Stream.value(profiles));

      expect(useCase.call(), emits(profiles));
    });

    test('emits multiple updates sequentially', () async {
      final controller = StreamController<List<DeviceProfile>>();
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => controller.stream);

      final first = [_profile(id: 1)];
      final second = [_profile(id: 1), _profile(id: 2)];
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
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => Stream.value([]));

      expect(useCase.call(), emits(<DeviceProfile>[]));
    });

    test('forwards repository errors on the stream', () async {
      when(() => repository.watchSavedDeviceProfiles())
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
      when(() => repository.watchSavedDeviceProfiles())
          .thenAnswer((_) => const Stream.empty());

      await expectLater(useCase.call(), emitsDone);
    });
  });
}