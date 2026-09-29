import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pulse_track/features/settings/infrastructure/services/csv_workout_import_service.dart';
import 'package:share_plus/share_plus.dart' show XFile;

class _MockFilePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {}

/// Minimal [PlatformFile] backed by a real temp file.
base class _TempPlatformFile extends PlatformFile {
  _TempPlatformFile(this.file);

  final File file;

  @override
  Uri get uri => file.uri;

  @override
  String get name => file.uri.pathSegments.last;

  @override
  int lengthSync() => file.lengthSync();

  @override
  XFile get xFile => XFile(file.path);

  @override
  Future<int?> length() => file.length();

  @override
  Future<Uint8List> readAsBytes() =>
      file.readAsBytes().then(Uint8List.fromList);

  @override
  Stream<Uint8List> readAsByteStream() =>
      file.openRead().map(Uint8List.fromList);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFilePickerPlatform picker;
  late Directory workDir;

  setUpAll(() {
    registerFallbackValue(FileType.custom);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    picker = _MockFilePickerPlatform();
    FilePickerPlatform.instance = picker;
    workDir = Directory.systemTemp.createTempSync('csv_import_test_');

    when(
      () => picker.pickFile(
        type: any(named: 'type'),
        allowedExtensions: any(named: 'allowedExtensions'),
      ),
    ).thenAnswer((_) async => null);
  });

  tearDown(() {
    if (workDir.existsSync()) workDir.deleteSync(recursive: true);
  });

  File writeFile(String name, List<int> bytes) {
    final file = File('${workDir.path}/$name')..writeAsBytesSync(bytes);
    return file;
  }

  void pick(File file) {
    when(
      () => picker.pickFile(
        type: any(named: 'type'),
        allowedExtensions: any(named: 'allowedExtensions'),
      ),
    ).thenAnswer((_) async => _TempPlatformFile(file));
  }

  const csv =
      'StartTime,EndTime,AvgBpm,MaxBpm,BpmSamples\n'
      '2026-07-28T10:00:00.000Z,2026-07-28T10:30:00.000Z,130,165,120;130\n';

  group('CsvWorkoutImportService.pickAndParseCsv', () {
    test('returns null when the user cancels the picker', () async {
      const service = CsvWorkoutImportService();

      expect(await service.pickAndParseCsv(), isNull);
    });

    test('parses the picked csv file', () async {
      pick(writeFile('w.csv', csv.codeUnits));
      const service = CsvWorkoutImportService();

      final analysis = await service.pickAndParseCsv();

      expect(analysis, isNotNull);
      expect(analysis!.validSessions.length, 1);
      expect(analysis.validSessions.first.avgBpm, 130);
      expect(analysis.skippedRowCount, 0);
    });

    test('strips a leading UTF-8 BOM', () async {
      pick(writeFile('w.csv', [0xEF, 0xBB, 0xBF, ...csv.codeUnits]));
      const service = CsvWorkoutImportService();

      final analysis = await service.pickAndParseCsv();

      expect(analysis, isNotNull);
      expect(analysis!.validSessions.length, 1);
    });

    test('throws FileTooLargeException past the 5 MB limit', () async {
      final big = writeFile(
        'w.csv',
        List<int>.filled(CsvWorkoutImportService.maxFileSizeBytes + 1, 0x2C),
      );
      pick(big);
      const service = CsvWorkoutImportService();

      await expectLater(
        service.pickAndParseCsv(),
        throwsA(
          isA<FileTooLargeException>().having(
            (e) => e.maxBytes,
            'maxBytes',
            CsvWorkoutImportService.maxFileSizeBytes,
          ),
        ),
      );
    });
  });

  group('FileTooLargeException', () {
    test('message mentions the megabyte limit', () {
      const e = FileTooLargeException(
        maxBytes: CsvWorkoutImportService.maxFileSizeBytes,
      );

      expect(e.toString(), contains('5 MB'));
    });
  });
}
