import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../workout/infrastructure/models/workout_session_dto.dart';

/// Utility for exporting heart rate workout sessions to CSV and sharing them
/// via the native system share sheet.
///
/// Generates an RFC 4180 compliant CSV file containing timestamp, BPM, and
/// elapsed seconds for each sample, saves it to the device's temporary
/// directory, and triggers the share sheet.
class HeartRateExportHelper {
  HeartRateExportHelper._();

  /// Exports [session] as a CSV file and opens the native share sheet.
  ///
  /// The CSV contains three columns: `Timestamp`, `BPM`, and `Elapsed_Seconds`.
  /// Timestamps are computed by adding the elapsed duration of each sample
  /// index to [WorkoutSessionDto.startTime]. BPM values come directly from
  /// [WorkoutSessionDto.bpmSamples]. Elapsed seconds are relative to the
  /// session start time.
  ///
  /// Shows a snackbar on [context] with a success or error message.
  /// [context] must remain valid for the duration of the snackbar display;
  /// the method checks [NavigatorState.canPop] after each [await] to avoid
  /// accessing a disposed context.
  static Future<void> shareWorkoutAsCsv(
    BuildContext context,
    WorkoutSessionDto session,
  ) async {
    // Capture navigator and scaffold messenger before any await to guard
    // against the context being unmounted during the async file I/O.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      final csv = _generateCsv(session);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'heart_rate_workout_${session.startTime.millisecondsSinceEpoch}.csv';
      final tempPath = '${tempDir.path}/$fileName';
      final file = File(tempPath);
      await file.writeAsString(csv);

      // Guard: the user may have navigated away while the file was being
      // written to disk.
      if (!navigator.canPop()) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Workout HR Export',
      );

      // Guard: the share sheet may have caused the route to pop.
      if (!navigator.canPop()) return;

      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Workout exported and ready to share'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // The share sheet is asynchronous; if we reach the catch block the
      // user is still on-screen, so it is safe to show a snackbar.
      if (!navigator.canPop()) return;

      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to export workout: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Generates an RFC 4180 compliant CSV string from [session].
  static String _generateCsv(WorkoutSessionDto session) {
    const header = 'Timestamp,BPM,Elapsed_Seconds';
    final lines = <String>[header];

    final sampleCount = session.bpmSamples.length;
    if (sampleCount == 0) {
      return lines.join('\n');
    }

    final totalDuration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    for (var i = 0; i < sampleCount; i++) {
      final elapsed = totalDuration.inMilliseconds > 0
          ? Duration(
              milliseconds: (i / (sampleCount - 1) * totalDuration.inMilliseconds).toInt(),
            )
          : Duration.zero;

      final timestamp = session.startTime.add(elapsed);
      final formattedTimestamp = _formatTimestamp(timestamp);
      final bpm = session.bpmSamples[i];
      final elapsedSeconds = elapsed.inSeconds;

      // RFC 4180: quote fields that may contain commas or special characters.
      lines.add('"$formattedTimestamp",$bpm,$elapsedSeconds');
    }

    return lines.join('\n');
  }

  /// Formats [date] as `yyyy-MM-dd HH:mm:ss`.
  static String _formatTimestamp(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

}
