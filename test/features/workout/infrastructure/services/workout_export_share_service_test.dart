import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/services/workout_export_service.dart';
import 'package:pulse_track/features/workout/infrastructure/services/workout_export_share_service.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

class _MockWorkoutExportService extends Mock implements WorkoutExportService {}

WorkoutSession _session({int id = 7}) {
  return WorkoutSession(
    id: id,
    startTime: DateTime(2026, 7, 28, 10),
    endTime: DateTime(2026, 7, 28, 10, 30),
    avgBpm: 130,
    maxBpm: 165,
    bpmSamples: const [120, 130],
    sensorLocationIndex: 1,
    deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
    deviceName: 'Polar H10',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockWorkoutExportService exportService;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(_session());
  });

  setUp(() {
    exportService = _MockWorkoutExportService();
    tempDir = Directory.systemTemp.createTempSync('export_share_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('WorkoutExportShareService.exportAndShareSession', () {
    test(
      'writes the csv to a per-session file then rethrows share failure',
      () async {
        when(() => exportService.generateCsv(any()))
            .thenAnswer((_) async => 'a,b\n1,2\n');
        final service = WorkoutExportShareService(exportService);

        // No share-sheet platform in unit tests: the share call throws and
        // the service rethrows after writing the file.
        await expectLater(
          service.exportAndShareSession(_session(), shareText: 'Share!'),
          throwsA(anything),
        );

        final file = File('${tempDir.path}/pulsetrack_workout_7.csv');
        expect(file.existsSync(), isTrue);
        expect(file.readAsStringSync(), 'a,b\n1,2\n');
      },
    );

    test('rethrows when csv generation fails without writing a file', () async {
      when(() => exportService.generateCsv(any()))
          .thenThrow(Exception('render failed'));
      final service = WorkoutExportShareService(exportService);

      await expectLater(
        service.exportAndShareSession(_session(), shareText: 'Share!'),
        throwsA(isA<Exception>()),
      );
      expect(
        File('${tempDir.path}/pulsetrack_workout_7.csv').existsSync(),
        isFalse,
      );
    });

    test('removes stale export files but keeps unrelated ones', () async {
      when(() => exportService.generateCsv(any()))
          .thenAnswer((_) async => 'a,b\n1,2\n');
      final service = WorkoutExportShareService(exportService);
      final stale = File('${tempDir.path}/pulsetrack_workout_1.csv')
        ..writeAsStringSync('old');
      final unrelated = File('${tempDir.path}/notes.txt')
        ..writeAsStringSync('keep');

      await expectLater(
        service.exportAndShareSession(_session(), shareText: 'Share!'),
        throwsA(anything),
      );

      expect(stale.existsSync(), isFalse);
      expect(unrelated.readAsStringSync(), 'keep');
    });
  });

  group('WorkoutExportShareService.exportAndShareAllSessions', () {
    test('writes the bulk csv then rethrows share failure', () async {
      when(() => exportService.generateAllSessionsCsv(any()))
          .thenAnswer((_) async => 'bulk\n');
      final service = WorkoutExportShareService(exportService);

      await expectLater(
        service.exportAndShareAllSessions([_session()], shareText: 'Share!'),
        throwsA(anything),
      );

      final file = File('${tempDir.path}/pulsetrack_workouts_export.csv');
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), 'bulk\n');
    });

    test('rethrows when bulk generation fails', () async {
      when(() => exportService.generateAllSessionsCsv(any()))
          .thenThrow(Exception('render failed'));
      final service = WorkoutExportShareService(exportService);

      await expectLater(
        service.exportAndShareAllSessions([_session()], shareText: 'Share!'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
