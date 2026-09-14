import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/settings/domain/services/csv_workout_importer.dart';

part 'csv_workout_import_service.g.dart';

/// Exception thrown when the selected CSV file exceeds the memory safety limit.
class FileTooLargeException implements Exception {
  /// Maximum permitted byte length.
  final int maxBytes;

  /// Creates a [FileTooLargeException].
  const FileTooLargeException({required this.maxBytes});

  @override
  String toString() =>
      'FileTooLargeException: file exceeds ${maxBytes ~/ (1024 * 1024)} MB';
}

/// Coordinates file picking from device storage and delegating
/// CSV parsing to [CsvWorkoutImporter].
class CsvWorkoutImportService {
  /// Safety threshold (5 MB) preventing out-of-memory errors on massive files.
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  final CsvWorkoutImporter _importer;

  /// Creates a [CsvWorkoutImportService].
  const CsvWorkoutImportService({CsvWorkoutImporter? importer})
    : _importer = importer ?? const CsvWorkoutImporter();

  /// Prompts user to pick a CSV file and parses it into [CsvWorkoutImportAnalysis].
  ///
  /// Returns `null` if user cancels the picker.
  Future<CsvWorkoutImportAnalysis?> pickAndParseCsv() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    final path = picked?.path;
    if (path == null) return null;

    final file = File(path);
    if (await file.length() > maxFileSizeBytes) {
      throw const FileTooLargeException(maxBytes: maxFileSizeBytes);
    }

    final bytes = await file.readAsBytes();
    var content = utf8.decode(bytes, allowMalformed: true);

    // Strip leading UTF-8 BOM if present
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
    }

    return _importer.parse(content);
  }
}

/// Riverpod provider supplying a singleton instance of [CsvWorkoutImportService].
@riverpod
CsvWorkoutImportService csvWorkoutImportService(Ref ref) {
  return const CsvWorkoutImportService();
}
