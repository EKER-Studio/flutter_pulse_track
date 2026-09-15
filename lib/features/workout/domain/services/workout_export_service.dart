import 'package:csv/csv.dart';

import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Domain service for exporting workout sessions into universal CSV format.
class WorkoutExportService {
  /// Generates a standardized CSV representation of a [session].
  ///
  /// Maps all heart rate samples in [session.bpmSamples] to a tabular structure
  /// containing timestamp, BPM, estimated R-R interval in ms, and sensor location.
  /// Returns a [Future] completing with the formatted CSV string.
  Future<String> generateCsv(WorkoutSession session) async {
    final rows = <List<dynamic>>[
      <dynamic>[
        'Timestamp',
        'HeartRate(bpm)',
        'RR_Interval(ms)',
        'SensorLocation',
      ],
    ];

    final sampleCount = session.bpmSamples.length;
    if (sampleCount == 0) {
      return Csv().encode(rows);
    }

    final totalDuration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    final divisor = sampleCount > 1 ? sampleCount - 1 : 1;

    for (var i = 0; i < sampleCount; i++) {
      final elapsedMs = totalDuration.inMilliseconds > 0
          ? (i / divisor * totalDuration.inMilliseconds).round()
          : i * 1000;

      final timestamp = session.startTime.add(
        Duration(milliseconds: elapsedMs),
      );
      final bpm = session.bpmSamples[i];
      final rrIntervalMs = bpm > 0 ? (60000 / bpm).round() : 0;
      final sensorLocation = session.sensorLocationIndex;

      rows.add(<dynamic>[
        timestamp.toIso8601String(),
        bpm,
        rrIntervalMs,
        sensorLocation,
      ]);
    }

    return Csv().encode(rows);
  }

  /// Generates a standardized multi-session CSV representation of [sessions].
  ///
  /// Maps each workout session to a row with timestamps, aggregates, and semicolon-separated BPM samples.
  /// @param sessions The list of workout sessions to serialize.
  Future<String> generateAllSessionsCsv(List<WorkoutSession> sessions) async {
    final rows = <List<dynamic>>[
      <dynamic>[
        'StartTime',
        'EndTime',
        'AvgBpm',
        'MaxBpm',
        'BpmSamples',
        'SensorLocation',
        'DeviceMacAddress',
        'DeviceName',
      ],
    ];

    for (final session in sessions) {
      rows.add(<dynamic>[
        session.startTime.toIso8601String(),
        session.endTime?.toIso8601String() ??
            session.startTime.toIso8601String(),
        session.avgBpm,
        session.maxBpm,
        session.bpmSamples.join(';'),
        session.sensorLocationIndex,
        session.deviceMacAddress,
        session.deviceName,
      ]);
    }

    return Csv().encode(rows);
  }
}
