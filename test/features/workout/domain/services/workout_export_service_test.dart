import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/services/workout_export_service.dart';

void main() {
  late WorkoutExportService exportService;

  setUp(() {
    exportService = WorkoutExportService();
  });

  group('WorkoutExportService generateCsv', () {
    test(
      'generateCsv creates correct header and tabular rows for a valid session',
      () async {
        final startTime = DateTime.utc(2026, 7, 28, 10, 0, 0);
        final endTime = DateTime.utc(2026, 7, 28, 10, 10, 0);

        final session = WorkoutSession(
          id: 42,
          startTime: startTime,
          endTime: endTime,
          avgBpm: 120,
          maxBpm: 150,
          bpmSamples: [100, 120, 150],
          sensorLocationIndex: 1, // Chest
          deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
          deviceName: 'Polar H10',
        );

        final csvContent = await exportService.generateCsv(session);
        final lines = csvContent.trim().split('\r\n');

        expect(lines.length, 4);
        expect(
          lines[0],
          'Timestamp,HeartRate(bpm),RR_Interval(ms),SensorLocation',
        );

        // Verify row 1 (BPM 100 -> RR_Interval ~600ms)
        expect(lines[1].contains('100'), isTrue);
        expect(lines[1].contains('600'), isTrue);
        expect(lines[1].endsWith(',1'), isTrue);

        // Verify row 2 (BPM 120 -> RR_Interval 500ms)
        expect(lines[2].contains('120'), isTrue);
        expect(lines[2].contains('500'), isTrue);

        // Verify row 3 (BPM 150 -> RR_Interval 400ms)
        expect(lines[3].contains('150'), isTrue);
        expect(lines[3].contains('400'), isTrue);
      },
    );

    test(
      'generateCsv returns header only when bpmSamples list is empty',
      () async {
        final session = WorkoutSession(
          id: 101,
          startTime: DateTime.utc(2026, 7, 28, 10, 0, 0),
          endTime: DateTime.utc(2026, 7, 28, 10, 0, 5),
          avgBpm: 0,
          maxBpm: 0,
          bpmSamples: const [],
          sensorLocationIndex: 0,
          deviceMacAddress: '11:22:33:44:55:66',
          deviceName: 'Unknown Sensor',
        );

        final csvContent = await exportService.generateCsv(session);
        final lines = csvContent.trim().split('\r\n');

        expect(lines.length, 1);
        expect(
          lines[0],
          'Timestamp,HeartRate(bpm),RR_Interval(ms),SensorLocation',
        );
      },
    );

    test('generateCsv handles bpm zero as RR 0', () async {
      final session = WorkoutSession(
        id: 2,
        startTime: DateTime.utc(2026, 7, 28, 10, 0, 0),
        endTime: DateTime.utc(2026, 7, 28, 10, 1, 0),
        avgBpm: 0,
        maxBpm: 0,
        bpmSamples: [0, 60],
        sensorLocationIndex: 2,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      final csv = await exportService.generateCsv(session);
      final lines = csv.trim().split('\r\n');
      expect(lines[1].contains(',0,'), isTrue);
      expect(lines[2].contains('1000'), isTrue);
    });

    test('generateCsv handles single sample without division by zero', () async {
      final session = WorkoutSession(
        id: 3,
        startTime: DateTime.utc(2026, 7, 28, 10, 0, 0),
        endTime: DateTime.utc(2026, 7, 28, 10, 5, 0),
        avgBpm: 80,
        maxBpm: 80,
        bpmSamples: [80],
        sensorLocationIndex: 3,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      final csv = await exportService.generateCsv(session);
      final lines = csv.trim().split('\r\n');
      expect(lines.length, 2);
      expect(lines[1].contains('80'), isTrue);
      expect(lines[1].contains('750'), isTrue);
    });

    test('generateCsv uses i*1000 fallback when endTime is null', () async {
      final start = DateTime.utc(2026, 7, 28, 10, 0, 0);
      final session = WorkoutSession(
        id: 4,
        startTime: start,
        endTime: null,
        avgBpm: 70,
        maxBpm: 70,
        bpmSamples: [70, 70, 70],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      final csv = await exportService.generateCsv(session);
      final lines = csv.trim().split('\r\n');
      expect(lines.length, 4);
      expect(lines[1].contains(start.toIso8601String()), isTrue);
      expect(lines[2].contains(start.add(const Duration(seconds: 1)).toIso8601String()), isTrue);
    });

    test('generateCsv encodes sensorLocationIndex correctly', () async {
      final session = WorkoutSession(
        id: 5,
        startTime: DateTime.utc(2026, 7, 28, 10, 0, 0),
        endTime: DateTime.utc(2026, 7, 28, 10, 10, 0),
        avgBpm: 90,
        maxBpm: 90,
        bpmSamples: [90, 90],
        sensorLocationIndex: 5,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      final csv = await exportService.generateCsv(session);
      expect(csv.contains(',5'), isTrue);
    });

    test('generateCsv distributes timestamps across totalDuration', () async {
      final start = DateTime.utc(2026, 7, 28, 10, 0, 0);
      final end = DateTime.utc(2026, 7, 28, 10, 1, 0);
      final session = WorkoutSession(
        id: 6,
        startTime: start,
        endTime: end,
        avgBpm: 60,
        maxBpm: 60,
        bpmSamples: [60, 60, 60],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Test',
      );

      final csv = await exportService.generateCsv(session);
      final lines = csv.trim().split('\r\n');
      expect(lines[1].contains(start.toIso8601String()), isTrue);
      expect(lines[3].contains(end.toIso8601String()), isTrue);
    });
  });
}
