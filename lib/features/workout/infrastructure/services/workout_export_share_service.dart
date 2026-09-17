import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/services/workout_export_service.dart';

/// Infrastructure service exporting workout sessions to CSV files and sharing
/// them via the platform share sheet.
///
/// Pure CSV generation lives in the domain [WorkoutExportService]; this class
/// only handles file I/O ([getTemporaryDirectory], [File]) and [SharePlus].
class WorkoutExportShareService {
  /// Creates a service delegating CSV generation to [exportService].
  WorkoutExportShareService([WorkoutExportService? exportService])
    : _exportService = exportService ?? WorkoutExportService();

  final WorkoutExportService _exportService;

  /// Exports [session] to a CSV file in the temporary directory and opens the system share sheet.
  ///
  /// Takes the target [session] to export and the localized [shareText]
  /// shown in the share sheet (built by the caller via `AppLocalizations`,
  /// since this layer has no `BuildContext`).
  /// Returns a [Future] completing when the file is written and passed to [SharePlus].
  Future<void> exportAndShareSession(
    WorkoutSession session, {
    required String shareText,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      await _cleanupOldExportFiles(tempDir);

      final csvContent = await _exportService.generateCsv(session);
      final filePath = '${tempDir.path}/pulsetrack_workout_${session.id}.csv';
      final file = File(filePath);

      await file.writeAsString(csvContent);
      log.i(
        '[WorkoutExportShareService] CSV generated at $filePath (${csvContent.length} bytes)',
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: shareText),
      );
    } on Object catch (e, st) {
      log.e(
        '[WorkoutExportShareService] Failed to export workout session #${session.id}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Exports all [sessions] to a CSV file in the temporary directory and opens the system share sheet.
  ///
  /// Takes the list of workout [sessions] to export and the localized
  /// [shareText] shown in the share sheet.
  /// Returns a [Future] completing when the file is written and shared.
  Future<void> exportAndShareAllSessions(
    List<WorkoutSession> sessions, {
    required String shareText,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      await _cleanupOldExportFiles(tempDir);

      final csvContent = await _exportService.generateAllSessionsCsv(sessions);
      final filePath = '${tempDir.path}/pulsetrack_workouts_export.csv';
      final file = File(filePath);

      await file.writeAsString(csvContent);
      log.i(
        '[WorkoutExportShareService] Bulk CSV generated at $filePath (${csvContent.length} bytes)',
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: shareText),
      );
    } on Object catch (e, st) {
      log.e(
        '[WorkoutExportShareService] Failed to export all workout sessions',
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
            entity.path.contains('pulsetrack_workout') &&
            entity.path.endsWith('.csv')) {
          try {
            await entity.delete();
            log.d(
              '[WorkoutExportShareService] Cleaned up old temp export: ${entity.path}',
            );
          } on Object catch (e) {
            log.w(
              '[WorkoutExportShareService] Failed to delete temp file ${entity.path}',
              error: e,
            );
          }
        }
      }
    } on Object catch (e) {
      log.w(
        '[WorkoutExportShareService] Error scanning temp dir for old exports',
        error: e,
      );
    }
  }
}
