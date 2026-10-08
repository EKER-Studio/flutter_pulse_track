import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/workout_session_recorder.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';

class _MockSaveWorkoutSessionUseCase extends Mock
    implements SaveWorkoutSessionUseCase {}

class _MockSavePartialWorkoutSessionUseCase extends Mock
    implements SavePartialWorkoutSessionUseCase {}

void main() {
  late _MockSaveWorkoutSessionUseCase mockSave;
  late _MockSavePartialWorkoutSessionUseCase mockSavePartial;
  late WorkoutSessionRecorder recorder;

  setUp(() {
    mockSave = _MockSaveWorkoutSessionUseCase();
    mockSavePartial = _MockSavePartialWorkoutSessionUseCase();
    recorder = WorkoutSessionRecorder(
      saveWorkoutSessionUseCase: mockSave,
      savePartialWorkoutSessionUseCase: mockSavePartial,
    );
  });

  tearDown(() {
    recorder.stopCheckpointTimer();
  });

  group('WorkoutSessionRecorder', () {
    test('initial state has no samples and is not saving', () {
      expect(recorder.hasSamples, isFalse);
      expect(recorder.isSaveInProgress, isFalse);
    });

    test('startNewSession resets and initializes session', () {
      recorder.recordSample(120);
      expect(recorder.hasSamples, isTrue);

      recorder.startNewSession(deviceId: 'DEV:01', deviceName: 'Polar H10');
      expect(recorder.hasSamples, isFalse);
    });

    test('recordSample accumulates samples and tracks max BPM', () {
      recorder.startNewSession(deviceId: 'DEV:01', deviceName: 'Polar H10');
      recorder.recordSample(100);
      recorder.recordSample(140);
      recorder.recordSample(120);

      expect(recorder.hasSamples, isTrue);
    });

    test('checkpoint does nothing if not connected or no samples', () async {
      recorder.startNewSession(deviceId: 'DEV:01', deviceName: 'Polar H10');
      await recorder.checkpoint(isConnected: false);

      verifyNever(
        () => mockSavePartial.call(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
        ),
      );
    });

    test(
      'checkpoint invokes savePartial when connected with samples',
      () async {
        when(
          () => mockSavePartial.call(
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

        recorder.startNewSession(deviceId: 'DEV:01', deviceName: 'Polar H10');
        recorder.setSensorLocationIndex(1);
        recorder.recordSample(120);
        recorder.recordSample(140);

        await recorder.checkpoint(isConnected: true);

        verify(
          () => mockSavePartial.call(
            startTime: any(named: 'startTime'),
            samples: [120, 140],
            sensorLocationIndex: 1,
            macAddress: 'DEV:01',
            name: 'Polar H10',
            avgBpm: 130,
            maxBpm: 140,
          ),
        ).called(1);
      },
    );

    test(
      'saveFinalSession invokes saveWorkoutSessionUseCase and resets state',
      () async {
        when(
          () => mockSave.call(
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
        ).thenAnswer((_) async => 99);

        recorder.startNewSession(deviceId: 'DEV:01', deviceName: 'Polar H10');
        recorder.setSensorLocationIndex(2);
        recorder.recordSample(110);
        recorder.recordSample(130);

        await recorder.saveFinalSession();

        verify(
          () => mockSave.call(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
            samples: [110, 130],
            sensorLocationIndex: 2,
            macAddress: 'DEV:01',
            name: 'Polar H10',
            avgBpm: 120,
            maxBpm: 130,
          ),
        ).called(1);

        expect(recorder.hasSamples, isFalse);
      },
    );
  });
}
