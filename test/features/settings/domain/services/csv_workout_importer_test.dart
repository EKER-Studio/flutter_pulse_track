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
      expect(session.startTime, DateTime.utc(2026, 7, 28, 10));
      expect(session.endTime, DateTime.utc(2026, 7, 28, 10, 10));
      expect(analysis.earliestDate, DateTime.utc(2026, 7, 28, 10));
      expect(analysis.latestDate, DateTime.utc(2026, 7, 28, 10, 10));
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
      expect(session1.startTime, DateTime.utc(2026, 7, 28, 10));
      expect(session1.endTime, DateTime.utc(2026, 7, 28, 10, 30));
      expect(session1.avgBpm, 130);
      expect(session1.maxBpm, 165);
      expect(session1.bpmSamples, [120, 130, 145, 165]);
      expect(session1.sensorLocationIndex, 1);
      expect(session1.deviceMacAddress, 'AA:BB:CC:DD:EE:FF');
      expect(session1.deviceName, 'Polar H10');

      final session2 = analysis.validSessions[1];
      expect(session2.startTime, DateTime.utc(2026, 7, 29, 8));
      expect(session2.deviceName, 'Garmin HRM');
      expect(analysis.earliestDate, DateTime.utc(2026, 7, 28, 10));
      expect(analysis.latestDate, DateTime.utc(2026, 7, 29, 8, 45));
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
        expect(analysis.earliestDate, isNull);
        expect(analysis.latestDate, isNull);
      },
    );

    test('parses CRLF line endings in data rows', () {
      const csv =
          'Timestamp,HeartRate(bpm)\r\n'
          '2026-07-28T10:00:00.000Z,100\r\n'
          '2026-07-28T10:05:00.000Z,140\r\n';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      expect(analysis.skippedRowCount, 0);
      expect(analysis.validSessions.first.bpmSamples, [100, 140]);
    });

    test('skips malformed time-series rows and parses the rest', () {
      const csv = '''
Timestamp,HeartRate(bpm)
2026-07-28T10:00:00.000Z,100
not-a-date,120
2026-07-28T10:05:00.000Z,not-a-bpm

2026-07-28T10:10:00.000Z,120
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      expect(analysis.skippedRowCount, 2);
      expect(analysis.validSessions.first.bpmSamples, [100, 120]);
    });

    test('returns empty analysis when all time-series rows are invalid', () {
      const csv = '''
Timestamp,HeartRate(bpm)
not-a-date,120
2026-07-28T10:05:00.000Z,not-a-bpm
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions, isEmpty);
      expect(analysis.skippedRowCount, 2);
    });

    test('parses alternative multi-session header spellings', () {
      const csv = '''
start_time,end_time,avg_bpm,max_bpm,bpm_samples,sensor_location,mac,name
2026-07-28T10:00:00.000Z,2026-07-28T10:30:00.000Z,0,0,"120,130,140",1,AA:BB:CC,Polar
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      final session = analysis.validSessions.first;
      // avg/max recomputed from comma-separated samples when columns are 0.
      expect(session.bpmSamples, [120, 130, 140]);
      expect(session.avgBpm, 130);
      expect(session.maxBpm, 140);
      expect(session.deviceMacAddress, 'AA:BB:CC');
      expect(session.deviceName, 'Polar');
    });

    test('falls back to IMPORTED identity when columns are missing', () {
      const csv = '''
StartTime,EndTime,AvgBpm,MaxBpm,BpmSamples
2026-07-28T10:00:00.000Z,2026-07-28T10:30:00.000Z,130,165,120;130
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      final session = analysis.validSessions.first;
      expect(session.deviceMacAddress, 'IMPORTED');
      expect(session.deviceName, 'Imported Session');
    });

    test('falls back to IMPORTED identity when values are blank', () {
      const csv = '''
StartTime,DeviceMacAddress,DeviceName
2026-07-28T10:00:00.000Z,,
''';

      final analysis = importer.parse(csv);

      expect(analysis.validSessions.length, 1);
      expect(analysis.validSessions.first.deviceMacAddress, 'IMPORTED');
      expect(analysis.validSessions.first.deviceName, 'Imported Session');
    });
  });
}
