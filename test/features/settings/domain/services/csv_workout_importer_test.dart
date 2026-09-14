import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/settings/domain/services/csv_workout_importer.dart';

void main() {
  late CsvWorkoutImporter importer;

  setUp(() {
    importer = const CsvWorkoutImporter();
  });

  group('CsvWorkoutImporter', () {
    test('returns empty analysis when CSV string is empty or whitespace', () {
      final analysisEmpty = importer.parse('');
      expect(analysisEmpty.validSessions, isEmpty);
      expect(analysisEmpty.skippedRowCount, 0);

      final analysisWhitespace = importer.parse('   \n  \r\n  ');
      expect(analysisWhitespace.validSessions, isEmpty);
      expect(analysisWhitespace.skippedRowCount, 0);
    });

    test('parses single-session time series CSV format accurately', () {
      const csv = '''
Timestamp,HeartRate(bpm),RR_Interval(ms),SensorLocation
2026-07-28T10:00:00.000Z,100,600,1
2026-07-28T10:05:00.000Z,140,428,1
2026-07-28T10:10:00.000Z,120,500,1
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      expect(analysis.skippedRowCount, 0);

      final session = analysis.validSessions.first;
      expect(session.bpmSamples, [100, 140, 120]);
      expect(session.avgBpm, 120);
      expect(session.maxBpm, 140);
      expect(session.sensorLocationIndex, 1);
      expect(session.startTime, DateTime.utc(2026, 7, 28, 10, 0, 0));
      expect(session.endTime, DateTime.utc(2026, 7, 28, 10, 10, 0));
      expect(analysis.earliestDate, DateTime.utc(2026, 7, 28, 10, 0, 0));
      expect(analysis.latestDate, DateTime.utc(2026, 7, 28, 10, 10, 0));
    });

    test('parses multi-session summary CSV format accurately', () {
      const csv = '''
StartTime,EndTime,AvgBpm,MaxBpm,BpmSamples,SensorLocation,DeviceMacAddress,DeviceName
2026-07-28T10:00:00.000Z,2026-07-28T10:30:00.000Z,130,165,120;130;145;165,1,AA:BB:CC:DD:EE:FF,Polar H10
2026-07-29T08:00:00.000Z,2026-07-29T08:45:00.000Z,142,175,130;140;150;175,2,11:22:33:44:55:66,Garmin HRM
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 2);
      expect(analysis.skippedRowCount, 0);

      final session1 = analysis.validSessions[0];
      expect(session1.startTime, DateTime.utc(2026, 7, 28, 10, 0, 0));
      expect(session1.endTime, DateTime.utc(2026, 7, 28, 10, 30, 0));
      expect(session1.avgBpm, 130);
      expect(session1.maxBpm, 165);
      expect(session1.bpmSamples, [120, 130, 145, 165]);
      expect(session1.sensorLocationIndex, 1);
      expect(session1.deviceMacAddress, 'AA:BB:CC:DD:EE:FF');
      expect(session1.deviceName, 'Polar H10');

      final session2 = analysis.validSessions[1];
      expect(session2.startTime, DateTime.utc(2026, 7, 29, 8, 0, 0));
      expect(session2.deviceName, 'Garmin HRM');
      expect(analysis.earliestDate, DateTime.utc(2026, 7, 28, 10, 0, 0));
      expect(analysis.latestDate, DateTime.utc(2026, 7, 29, 8, 45, 0));
    });

    test('counts invalid rows in skippedRowCount and parses valid rows', () {
      const csv = '''
StartTime,EndTime,AvgBpm,MaxBpm,BpmSamples,SensorLocation,DeviceMacAddress,DeviceName
not-a-date,2026-07-28T10:30:00.000Z,130,165,120;130,1,AA:BB,Polar
2026-07-28T10:00:00.000Z,2026-07-28T10:30:00.000Z,130,165,120;130;140,1,AA:BB,Polar
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      expect(analysis.skippedRowCount, 1);
    });

    test(
      'returns skippedRowCount for completely unrecognized header format',
      () {
        const csv = '''
RandomColumn1,RandomColumn2,RandomColumn3
val1,val2,val3
val4,val5,val6
''';

        final analysis = importer.parse(csv);

        expect(analysis.validSessions, isEmpty);
        expect(analysis.skippedRowCount, 3);
      },
    );
  });
}
