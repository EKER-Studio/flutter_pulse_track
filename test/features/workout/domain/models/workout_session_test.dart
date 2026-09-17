import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

void main() {
  group('WorkoutSession', () {
    final start = DateTime(2026, 7, 23, 14);
    final end = DateTime(2026, 7, 23, 15, 30);

    test('constructor assigns all fields', () {
      final session = WorkoutSession(
        id: 1,
        startTime: start,
        endTime: end,
        avgBpm: 78,
        maxBpm: 142,
        bpmSamples: [60, 72, 88, 95, 100],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Polar H10',
      );

      expect(session.id, 1);
      expect(session.startTime, start);
      expect(session.endTime, end);
      expect(session.avgBpm, 78);
      expect(session.maxBpm, 142);
      expect(session.bpmSamples, [60, 72, 88, 95, 100]);
      expect(session.sensorLocationIndex, 0);
      expect(session.deviceMacAddress, 'AA:BB:CC:DD:EE:FF');
      expect(session.deviceName, 'Polar H10');
    });

    test('accepts null endTime', () {
      final session = WorkoutSession(
        id: 2,
        startTime: start,
        endTime: null,
        avgBpm: 72,
        maxBpm: 120,
        bpmSamples: [60, 72],
        sensorLocationIndex: 1,
        deviceMacAddress: '11:22:33:44:55:66',
        deviceName: 'Garmin',
      );

      expect(session.endTime, isNull);
    });

    test('accepts empty bpmSamples', () {
      final session = WorkoutSession(
        id: 3,
        startTime: start,
        endTime: null,
        avgBpm: 0,
        maxBpm: 0,
        bpmSamples: [],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      expect(session.bpmSamples, isEmpty);
    });

    test('rejects negative avgBpm', () {
      expect(
        () => WorkoutSession(
          id: 4,
          startTime: start,
          endTime: end,
          avgBpm: -1,
          maxBpm: 100,
          bpmSamples: [60],
          sensorLocationIndex: 0,
          deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
          deviceName: 'Test',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects negative maxBpm', () {
      expect(
        () => WorkoutSession(
          id: 5,
          startTime: start,
          endTime: end,
          avgBpm: 80,
          maxBpm: -5,
          bpmSamples: [60],
          sensorLocationIndex: 0,
          deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
          deviceName: 'Test',
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
