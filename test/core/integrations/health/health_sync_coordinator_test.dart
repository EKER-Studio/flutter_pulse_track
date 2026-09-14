import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/core/integrations/health/health_sync_coordinator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

class MockHealthService extends Mock implements HealthService {}

class MockWorkoutPersistenceRepository extends Mock
    implements WorkoutPersistenceRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthService mockHealthService;
  late MockWorkoutPersistenceRepository mockRepository;
  late HealthSyncCoordinator coordinator;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(
      WorkoutSession(
        id: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        avgBpm: 120,
        maxBpm: 150,
        bpmSamples: const [120],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB',
        deviceName: 'Device',
      ),
    );
  });

  setUp(() {
    mockHealthService = MockHealthService();
    mockRepository = MockWorkoutPersistenceRepository();
    coordinator = HealthSyncCoordinator(
      healthService: mockHealthService,
      repository: mockRepository,
    );
  });

  group('HealthSyncCoordinator.sync', () {
    test('exports local session missing from remote store', () async {
      final now = DateTime.now().toUtc();
      final localSession = WorkoutSession(
        id: 10,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
        avgBpm: 135,
        maxBpm: 160,
        bpmSamples: const [130, 140],
        sensorLocationIndex: 1,
        deviceMacAddress: '11:22:33:44:55:66',
        deviceName: 'Strap',
      );

      when(
        () => mockHealthService.fetchWorkoutHistory(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => []);

      when(() => mockRepository.watchWorkoutHistory())
          .thenAnswer((_) => Stream.value([localSession]));

      when(
        () => mockHealthService.writeWorkoutSession(
          session: any(named: 'session'),
        ),
      ).thenAnswer((_) async => true);

      final result = await coordinator.sync(
        lastSyncTime: now.subtract(const Duration(days: 1)),
      );

      expect(result, isNotNull);
      expect(result!.remoteCount, equals(0));
      expect(result.pushedLocalCount, equals(1));
      verify(() => mockHealthService.writeWorkoutSession(session: localSession))
          .called(1);
    });

    test(
      'skips session already present remotely within 60s tolerance',
      () async {
        final now = DateTime.now().toUtc();
        final sessionTime = now.subtract(const Duration(hours: 2));

        final localSession = WorkoutSession(
          id: 11,
          startTime: sessionTime,
          endTime: sessionTime.add(const Duration(minutes: 30)),
          avgBpm: 130,
          maxBpm: 155,
          bpmSamples: const [130],
          sensorLocationIndex: 1,
          deviceMacAddress: '11:22:33:44:55:66',
          deviceName: 'Strap',
        );

        final remotePoint = HealthDataPoint(
          uuid: 'remote-uuid-1',
          value: WorkoutHealthValue(
            workoutActivityType: HealthWorkoutActivityType.OTHER,
          ),
          type: HealthDataType.WORKOUT,
          unit: HealthDataUnit.NO_UNIT,
          dateFrom: sessionTime.add(const Duration(seconds: 15)),
          dateTo: sessionTime.add(const Duration(minutes: 30)),
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'source-device',
          sourceId: 'source-id',
          sourceName: 'Apple Health',
        );

        when(
          () => mockHealthService.fetchWorkoutHistory(
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).thenAnswer((_) async => [remotePoint]);

        when(() => mockRepository.watchWorkoutHistory())
            .thenAnswer((_) => Stream.value([localSession]));

        final result = await coordinator.sync();

        expect(result, isNotNull);
        expect(result!.remoteCount, equals(1));
        expect(result.pushedLocalCount, equals(0));
        verifyNever(
          () => mockHealthService.writeWorkoutSession(
            session: any(named: 'session'),
          ),
        );
      },
    );

    test('ignores incomplete sessions without endTime or samples', () async {
      final now = DateTime.now().toUtc();
      final incompleteSession = WorkoutSession(
        id: 12,
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: null,
        avgBpm: 120,
        maxBpm: 130,
        bpmSamples: const [],
        sensorLocationIndex: 1,
        deviceMacAddress: '11:22:33:44:55:66',
        deviceName: 'Strap',
      );

      when(
        () => mockHealthService.fetchWorkoutHistory(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => []);

      when(() => mockRepository.watchWorkoutHistory())
          .thenAnswer((_) => Stream.value([incompleteSession]));

      final result = await coordinator.sync();

      expect(result, isNotNull);
      expect(result!.pushedLocalCount, equals(0));
      verifyNever(
        () => mockHealthService.writeWorkoutSession(
          session: any(named: 'session'),
        ),
      );
    });

    test('returns null when health service throws', () async {
      when(
        () => mockHealthService.fetchWorkoutHistory(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenThrow(Exception('Service failure'));

      final result = await coordinator.sync();

      expect(result, isNull);
    });
  });

  group('HealthSyncCoordinator.exportSession', () {
    test('calls writeWorkoutSession and returns true on success', () async {
      final session = WorkoutSession(
        id: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        avgBpm: 130,
        maxBpm: 160,
        bpmSamples: const [130],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB',
        deviceName: 'Test',
      );

      when(() => mockHealthService.writeWorkoutSession(session: session))
          .thenAnswer((_) async => true);

      final result = await coordinator.exportSession(session);

      expect(result, isTrue);
      verify(() => mockHealthService.writeWorkoutSession(session: session))
          .called(1);
    });

    test('catches error and returns false on failure', () async {
      final session = WorkoutSession(
        id: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        avgBpm: 130,
        maxBpm: 160,
        bpmSamples: const [130],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB',
        deviceName: 'Test',
      );

      when(() => mockHealthService.writeWorkoutSession(session: session))
          .thenThrow(Exception('Export error'));

      final result = await coordinator.exportSession(session);

      expect(result, isFalse);
    });
  });
}
