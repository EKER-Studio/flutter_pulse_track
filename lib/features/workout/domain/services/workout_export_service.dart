import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

part 'workout_export_service.g.dart';

/// Domain service for exporting workout sessions into universal CSV format
/// and sharing them via system share dialogs.
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

  /// Exports [session] to a CSV file in the temporary directory and opens the system share sheet.
  ///
  /// Takes the target [session] to export.
  /// Returns a [Future] completing when the file is written and passed to [Share].
  Future<void> exportAndShareSession(WorkoutSession session) async {
    try {
      final tempDir = await getTemporaryDirectory();
      await _cleanupOldExportFiles(tempDir);

      final csvContent = await generateCsv(session);
      final filePath = '${tempDir.path}/pulsetrack_workout_${session.id}.csv';
      final file = File(filePath);

      await file.writeAsString(csvContent);
      log.i(
        '[WorkoutExportService] CSV generated at $filePath (${csvContent.length} bytes)',
      );

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'PulseTrack Workout Export #${session.id}');
    } catch (e, st) {
      log.e(
        '[WorkoutExportService] Failed to export workout session #${session.id}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> _cleanupOldExportFiles(Directory tempDir) async {
    try {
      if (!await tempDir.exists()) return;
      final entities = tempDir.listSync();
      for (final entity in entities) {
        if (entity is File &&
            entity.path.contains('pulsetrack_workout_') &&
            entity.path.endsWith('.csv')) {
          try {
            await entity.delete();
            log.d(
              '[WorkoutExportService] Cleaned up old temp export: ${entity.path}',
            );
          } catch (e) {
            log.w(
              '[WorkoutExportService] Failed to delete temp file ${entity.path}',
              error: e,
            );
          }
        }
      }
    } catch (e) {
      log.w(
        '[WorkoutExportService] Error scanning temp dir for old exports',
        error: e,
      );
    }
  }
}

/// Riverpod provider supplying a singleton instance of [WorkoutExportService].
@riverpod
WorkoutExportService workoutExportService(Ref ref) {
  return WorkoutExportService();
}
