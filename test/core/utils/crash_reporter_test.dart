import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/utils/crash_log.dart';
import 'package:pulse_track/core/utils/crash_reporter.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;

  setUp(() {
    docsDir = Directory.systemTemp.createTempSync('crash_report_test_');
    AppCrashReporter.setFirebaseAvailable(false);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return docsDir.path;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    AppCrashReporter.setFirebaseAvailable(false);
    if (docsDir.existsSync()) docsDir.deleteSync(recursive: true);
  });

  File logFile() => File('${docsDir.path}/$crashLogFileName');

  group('writeCrashLog', () {
    test(
      'creates the log file with timestamp, reason, error and stack',
      () async {
        final stack = StackTrace.current;

        await AppCrashReporter.writeCrashLog(
          Exception('boom'),
          stack,
          reason: 'test-reason',
        );

        final content = logFile().readAsStringSync();
        expect(content, contains('test-reason'));
        expect(content, contains('boom'));
        expect(content, contains(stack.toString().split('\n').first));
        // ISO-8601 timestamp prefix.
        expect(RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(content), isTrue);
      },
    );

    test('appends entries without truncating existing ones', () async {
      await AppCrashReporter.writeCrashLog(
        Exception('first'),
        StackTrace.empty,
      );
      await AppCrashReporter.writeCrashLog(
        Exception('second'),
        StackTrace.empty,
      );

      final content = logFile().readAsStringSync();
      expect(content, contains('first'));
      expect(content, contains('second'));
    });

    test('omits the reason marker when no reason is given', () async {
      await AppCrashReporter.writeCrashLog(
        Exception('plain'),
        StackTrace.empty,
      );

      expect(logFile().readAsStringSync(), isNot(contains('[Reason:')));
    });

    test('trims the oldest half once the file exceeds 1 MB', () async {
      // No double-newline delimiter: trim keeps nothing, then appends.
      logFile().writeAsStringSync('x' * (1024 * 1024 + 8));

      await AppCrashReporter.writeCrashLog(
        Exception('after-trim'),
        StackTrace.empty,
      );

      final content = logFile().readAsStringSync();
      expect(content.length, lessThan(1024 * 1024));
      expect(content, contains('after-trim'));
      expect(content.startsWith('x'), isFalse);
    });

    test(
      'trim keeps entries after the first boundary past the midpoint',
      () async {
        final filler = 'a' * (512 * 1024);
        logFile().writeAsStringSync(
          '${filler}OLD-MARKER\n\nKEEP-ME\n\n$filler',
        );

        await AppCrashReporter.writeCrashLog(
          Exception('after-trim'),
          StackTrace.empty,
        );

        final content = logFile().readAsStringSync();
        expect(content, isNot(contains('OLD-MARKER')));
        expect(content, contains('KEEP-ME'));
        expect(content, contains('after-trim'));
      },
    );
  });

  group('recordError', () {
    test('persists fatal errors with reason to the local log', () async {
      await AppCrashReporter.recordError(
        Exception('fatal-boom'),
        StackTrace.empty,
        reason: 'fatal-path',
        fatal: true,
      );

      final content = logFile().readAsStringSync();
      expect(content, contains('fatal-boom'));
      expect(content, contains('fatal-path'));
    });

    test('persists non-fatal errors to the local log', () async {
      await AppCrashReporter.recordError(Exception('oops'), StackTrace.empty);

      expect(logFile().readAsStringSync(), contains('oops'));
    });

    test('synthesizes a stack trace when none is provided', () async {
      await AppCrashReporter.recordError(Exception('no-stack'), null);

      expect(logFile().readAsStringSync(), contains('no-stack'));
    });

    test(
      'survives Crashlytics being flagged available without Firebase init',
      () async {
        AppCrashReporter.setFirebaseAvailable(true);

        await expectLater(
          AppCrashReporter.recordError(
            Exception('fb-missing'),
            StackTrace.empty,
          ),
          completes,
        );
        expect(logFile().readAsStringSync(), contains('fb-missing'));
      },
    );
  });
}
