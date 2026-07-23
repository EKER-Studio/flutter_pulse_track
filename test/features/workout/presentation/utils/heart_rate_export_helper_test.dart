import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_export_helper.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

WorkoutSession _session({
  int id = 0,
  DateTime? startTime,
  DateTime? endTime,
  int avgBpm = 75,
  int maxBpm = 120,
  List<int> bpmSamples = const [],
  int sensorLocationIndex = 0,
  String deviceMacAddress = '00:11:22:33:44:55',
  String deviceName = 'Test HR',
}) {
  return WorkoutSession(
    id: id,
    startTime: startTime ?? DateTime(2026, 7, 23, 14, 30, 0),
    endTime: endTime,
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    bpmSamples: bpmSamples,
    sensorLocationIndex: sensorLocationIndex,
    deviceMacAddress: deviceMacAddress,
    deviceName: deviceName,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('generateCsv', () {
    test('returns header only for empty samples', () {
      final session = _session(bpmSamples: []);
      final csv = HeartRateExportHelper.generateCsv(session);
      expect(csv, 'Timestamp,BPM,Elapsed_Seconds');
    });

    test('single sample with null endTime has zero elapsed', () {
      final session = _session(
        startTime: DateTime(2026, 1, 15, 10, 0, 0),
        endTime: null,
        bpmSamples: [72],
      );
      final csv = HeartRateExportHelper.generateCsv(session);
      final lines = csv.split('\n');
      expect(lines, hasLength(2));
      expect(lines[1], contains(',72,0'));
    });

    test('single sample with endTime has zero elapsed (divisor guard)', () {
      final session = _session(
        startTime: DateTime(2026, 1, 15, 10, 0, 0),
        endTime: DateTime(2026, 1, 15, 10, 30, 0),
        bpmSamples: [80],
      );
      final csv = HeartRateExportHelper.generateCsv(session);
      final lines = csv.split('\n');
      expect(lines, hasLength(2));
      expect(lines[1], contains(',80,0'));
    });

    test('two samples interpolates proportionally', () {
      final start = DateTime(2026, 1, 15, 10, 0, 0);
      final end = DateTime(2026, 1, 15, 10, 10, 0);
      final session = _session(
        startTime: start,
        endTime: end,
        bpmSamples: [60, 120],
      );
      final csv = HeartRateExportHelper.generateCsv(session);
      final lines = csv.split('\n');
      expect(lines, hasLength(3));
      expect(lines[1], contains(',60,0'));
      expect(lines[2], contains(',120,600'));
    });

    test('three samples interpolates evenly across duration', () {
      final start = DateTime(2026, 1, 15, 10, 0, 0);
      final end = DateTime(2026, 1, 15, 10, 0, 10);
      final session = _session(
        startTime: start,
        endTime: end,
        bpmSamples: [70, 80, 90],
      );
      final csv = HeartRateExportHelper.generateCsv(session);
      final lines = csv.split('\n');
      expect(lines, hasLength(4));
      expect(lines[1], contains(',70,0'));
      expect(lines[2], contains(',80,5'));
      expect(lines[3], contains(',90,10'));
    });

    test('quotes timestamp field per RFC 4180', () {
      final session = _session(
        startTime: DateTime(2026, 1, 15, 10, 0, 0),
        endTime: null,
        bpmSamples: [65],
      );
      final csv = HeartRateExportHelper.generateCsv(session);
      final lines = csv.split('\n');
      expect(lines[1], '"2026-01-15 10:00:00",65,0');
    });
  });

  group('formatTimestamp', () {
    test('formats date with double-digit components', () {
      final date = DateTime(2026, 12, 25, 8, 5, 3);
      expect(
        HeartRateExportHelper.formatTimestamp(date),
        '2026-12-25 08:05:03',
      );
    });

    test('pads single-digit month, day, hour, minute, second', () {
      final date = DateTime(2026, 1, 2, 3, 4, 5);
      expect(
        HeartRateExportHelper.formatTimestamp(date),
        '2026-01-02 03:04:05',
      );
    });

    test('handles year boundary dates', () {
      expect(
        HeartRateExportHelper.formatTimestamp(
          DateTime(1999, 12, 31, 23, 59, 59),
        ),
        '1999-12-31 23:59:59',
      );
      expect(
        HeartRateExportHelper.formatTimestamp(DateTime(2000, 1, 1, 0, 0, 0)),
        '2000-01-01 00:00:00',
      );
    });
  });

  }