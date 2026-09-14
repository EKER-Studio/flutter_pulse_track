import 'package:csv/csv.dart';

import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Result analysis produced when parsing workout sessions from CSV data.
class CsvWorkoutImportAnalysis {
  /// Valid workout sessions parsed from the CSV payload.
  final List<WorkoutSession> validSessions;

  /// Count of malformed or unparseable rows skipped during ingestion.
  final int skippedRowCount;

  /// Earliest start timestamp found across parsed sessions.
  final DateTime? earliestDate;

  /// Latest end or start timestamp found across parsed sessions.
  final DateTime? latestDate;

  /// Creates a [CsvWorkoutImportAnalysis] summary.
  const CsvWorkoutImportAnalysis({
    required this.validSessions,
    required this.skippedRowCount,
    this.earliestDate,
    this.latestDate,
  });
}

/// Domain service that parses CSV representations of workouts into domain entities.
class CsvWorkoutImporter {
  /// Default const constructor for [CsvWorkoutImporter].
  const CsvWorkoutImporter();

  /// Parses [rawCsv] content into a [CsvWorkoutImportAnalysis].
  ///
  /// Supports both multi-session export files and single-session time-series exports.
  CsvWorkoutImportAnalysis parse(String rawCsv) {
    if (rawCsv.trim().isEmpty) {
      return const CsvWorkoutImportAnalysis(
        validSessions: [],
        skippedRowCount: 0,
      );
    }

    final normalized = rawCsv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = Csv(
      fieldDelimiter: ',',
      lineDelimiter: '\n',
      dynamicTyping: false,
    ).decode(normalized);
    if (rows.isEmpty) {
      return const CsvWorkoutImportAnalysis(
        validSessions: [],
        skippedRowCount: 0,
      );
    }

    final header = rows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    // Determine format: Single session time-series vs Multi-session table
    if (header.contains('timestamp') &&
        (header.contains('heartrate(bpm)') ||
            header.contains('heartrate') ||
            header.contains('bpm'))) {
      return _parseTimeSeriesFormat(rows);
    } else if (header.contains('starttime') || header.contains('start_time')) {
      return _parseMultiSessionFormat(rows, header);
    } else {
      // Unknown header format; attempt best-effort fallback or return skipped rows
      return CsvWorkoutImportAnalysis(
        validSessions: const [],
        skippedRowCount: rows.length,
      );
    }
  }

  CsvWorkoutImportAnalysis _parseTimeSeriesFormat(List<List<dynamic>> rows) {
    final header = rows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();
    final timeIdx = header.indexOf('timestamp');
    var bpmIdx = header.indexOf('heartrate(bpm)');
    if (bpmIdx == -1) bpmIdx = header.indexOf('heartrate');
    if (bpmIdx == -1) bpmIdx = header.indexOf('bpm');
    final sensorIdx = header.indexOf('sensorlocation');

    final bpmSamples = <int>[];
    DateTime? firstTime;
    DateTime? lastTime;
    var skippedRows = 0;
    var sensorLocationIndex = 0;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty ||
          (row.length == 1 && row.first.toString().trim().isEmpty)) {
        continue;
      }
      try {
        final timeStr = row[timeIdx].toString().trim();
        final bpmStr = row[bpmIdx].toString().trim();
        final timestamp = DateTime.parse(timeStr);
        final bpm = int.parse(bpmStr);

        if (firstTime == null || timestamp.isBefore(firstTime)) {
          firstTime = timestamp;
        }
        if (lastTime == null || timestamp.isAfter(lastTime)) {
          lastTime = timestamp;
        }

        if (sensorIdx != -1 && sensorIdx < row.length) {
          final loc = int.tryParse(row[sensorIdx].toString().trim());
          if (loc != null) sensorLocationIndex = loc;
        }

        bpmSamples.add(bpm);
      } catch (_) {
        skippedRows++;
      }
    }

    if (bpmSamples.isEmpty || firstTime == null) {
      return CsvWorkoutImportAnalysis(
        validSessions: const [],
        skippedRowCount: skippedRows + (rows.length > 1 ? 0 : 1),
      );
    }

    var sum = 0;
    var max = 0;
    for (final sample in bpmSamples) {
      sum += sample;
      if (sample > max) max = sample;
    }
    final avg = (sum / bpmSamples.length).round();

    final session = WorkoutSession(
      id: 0,
      startTime: firstTime,
      endTime: lastTime ?? firstTime,
      avgBpm: avg,
      maxBpm: max,
      bpmSamples: bpmSamples,
      sensorLocationIndex: sensorLocationIndex,
      deviceMacAddress: 'IMPORTED',
      deviceName: 'Imported Session',
    );

    return CsvWorkoutImportAnalysis(
      validSessions: [session],
      skippedRowCount: skippedRows,
      earliestDate: firstTime,
      latestDate: lastTime ?? firstTime,
    );
  }

  CsvWorkoutImportAnalysis _parseMultiSessionFormat(
    List<List<dynamic>> rows,
    List<String> header,
  ) {
    final startIdx = header.indexWhere(
      (h) => h == 'starttime' || h == 'start_time',
    );
    final endIdx = header.indexWhere((h) => h == 'endtime' || h == 'end_time');
    final avgIdx = header.indexWhere((h) => h == 'avgbpm' || h == 'avg_bpm');
    final maxIdx = header.indexWhere((h) => h == 'maxbpm' || h == 'max_bpm');
    final samplesIdx = header.indexWhere(
      (h) => h == 'bpmsamples' || h == 'bpm_samples' || h == 'samples',
    );
    final sensorIdx = header.indexWhere(
      (h) => h == 'sensorlocation' || h == 'sensor_location',
    );
    final macIdx = header.indexWhere(
      (h) => h == 'deviceaddress' || h == 'devicemacaddress' || h == 'mac',
    );
    final nameIdx = header.indexWhere(
      (h) => h == 'devicename' || h == 'device_name' || h == 'name',
    );

    final validSessions = <WorkoutSession>[];
    var skippedRows = 0;
    DateTime? earliest;
    DateTime? latest;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty ||
          (row.length == 1 && row.first.toString().trim().isEmpty)) {
        continue;
      }
      try {
        final startStr = row[startIdx].toString().trim();
        final startTime = DateTime.parse(startStr);

        DateTime? endTime;
        if (endIdx != -1 && endIdx < row.length) {
          final endStr = row[endIdx].toString().trim();
          if (endStr.isNotEmpty) endTime = DateTime.tryParse(endStr);
        }

        final samples = <int>[];
        if (samplesIdx != -1 && samplesIdx < row.length) {
          final rawSamples = row[samplesIdx]
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .trim();
          if (rawSamples.isNotEmpty) {
            final delimiter = rawSamples.contains(';') ? ';' : ',';
            for (final part in rawSamples.split(delimiter)) {
              final parsed = int.tryParse(part.trim());
              if (parsed != null) samples.add(parsed);
            }
          }
        }

        var avg = avgIdx != -1 && avgIdx < row.length
            ? int.tryParse(row[avgIdx].toString().trim()) ?? 0
            : 0;
        var max = maxIdx != -1 && maxIdx < row.length
            ? int.tryParse(row[maxIdx].toString().trim()) ?? 0
            : 0;

        if (samples.isNotEmpty && (avg == 0 || max == 0)) {
          var sum = 0;
          for (final s in samples) {
            sum += s;
            if (s > max) max = s;
          }
          avg = (sum / samples.length).round();
        }

        final sensorLocation = sensorIdx != -1 && sensorIdx < row.length
            ? int.tryParse(row[sensorIdx].toString().trim()) ?? 0
            : 0;
        final mac = macIdx != -1 && macIdx < row.length
            ? row[macIdx].toString().trim()
            : 'IMPORTED';
        final name = nameIdx != -1 && nameIdx < row.length
            ? row[nameIdx].toString().trim()
            : 'Imported Session';

        final session = WorkoutSession(
          id: 0,
          startTime: startTime,
          endTime: endTime ?? startTime,
          avgBpm: avg,
          maxBpm: max,
          bpmSamples: samples,
          sensorLocationIndex: sensorLocation,
          deviceMacAddress: mac.isEmpty ? 'IMPORTED' : mac,
          deviceName: name.isEmpty ? 'Imported Session' : name,
        );

        validSessions.add(session);

        if (earliest == null || startTime.isBefore(earliest)) {
          earliest = startTime;
        }
        final checkEnd = endTime ?? startTime;
        if (latest == null || checkEnd.isAfter(latest)) {
          latest = checkEnd;
        }
      } catch (_) {
        skippedRows++;
      }
    }

    return CsvWorkoutImportAnalysis(
      validSessions: validSessions,
      skippedRowCount: skippedRows,
      earliestDate: earliest,
      latestDate: latest,
    );
  }
}
