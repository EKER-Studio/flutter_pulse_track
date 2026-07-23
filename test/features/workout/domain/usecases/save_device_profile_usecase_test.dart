import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockRepository extends Mock implements WorkoutPersistenceRepository {}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkoutPersistenceRepository repository;
  late SaveDeviceProfileUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = SaveDeviceProfileUseCase(repository);
    when(
      () => repository.saveDeviceProfile(
        macAddress: any(named: 'macAddress'),
        name: any(named: 'name'),
        sensorLocationIndex: any(named: 'sensorLocationIndex'),
      ),
    ).thenAnswer((_) async {});
  });

  group('call', () {
    test('delegates to repository.saveDeviceProfile', () async {
      await useCase(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        sensorLocationIndex: 1,
      );

      verify(
        () => repository.saveDeviceProfile(
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
        ),
      ).called(1);
    });

    test('forwards all required parameters unchanged', () async {
      await useCase(
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

    test('accepts empty name', () async {
      await useCase(
        macAddress: '00:00:00:00:00:00',
        name: '',
        sensorLocationIndex: 0,
      );

      verify(
        () => repository.saveDeviceProfile(
          macAddress: '00:00:00:00:00:00',
          name: '',
          sensorLocationIndex: 0,
        ),
      ).called(1);
    });

    test('accepts zero sensorLocationIndex', () async {
      await useCase(
        macAddress: '11:22:33:44:55:66',
        name: 'Test',
        sensorLocationIndex: 0,
      );

      verify(
        () => repository.saveDeviceProfile(
          macAddress: '11:22:33:44:55:66',
          name: 'Test',
          sensorLocationIndex: 0,
        ),
      ).called(1);
    });

    test('accepts iOS-style UUID as macAddress', () async {
      await useCase(
        macAddress: '12345678-ABCD-EF01-2345-6789ABCDEF01',
        name: 'Garmin HRM',
        sensorLocationIndex: 3,
      );

      verify(
        () => repository.saveDeviceProfile(
          macAddress: '12345678-ABCD-EF01-2345-6789ABCDEF01',
          name: 'Garmin HRM',
          sensorLocationIndex: 3,
        ),
      ).called(1);
    });

    test('propagates repository exceptions', () async {
      when(
        () => repository.saveDeviceProfile(
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
        ),
      ).thenThrow(Exception('Save failed'));

      expect(
        () => useCase(
          macAddress: 'AA:BB:CC:DD:EE:FF',
          name: 'Test',
          sensorLocationIndex: 1,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Save failed'),
          ),
        ),
      );
    });
  });
}
