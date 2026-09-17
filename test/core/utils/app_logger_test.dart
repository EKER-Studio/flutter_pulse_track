import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' hide ProductionFilter;
import 'package:pulse_track/core/utils/app_logger.dart';

void main() {
  group('ProductionFilter', () {
    test('returns true for all levels in debug mode', () {
      final filter = ProductionFilter();

      const validLevels = [
        Level.trace,
        Level.debug,
        Level.info,
        Level.warning,
        Level.error,
        Level.fatal,
      ];

      for (final level in validLevels) {
        expect(filter.shouldLog(LogEvent(level, 'test')), true);
      }
    });
  });

  group('FirebaseCrashlyticsOutput', () {
    test('returns early in debug mode without throwing when enableInDebug is false', () {
      final output = FirebaseCrashlyticsOutput();
      final event = LogEvent(Level.error, 'test error');

      expect(
        () => output.output(OutputEvent(event, ['test error'])),
        returnsNormally,
      );
    });

    test('does not throw with error details in debug mode when enableInDebug is false', () {
      final output = FirebaseCrashlyticsOutput();
      final event = LogEvent(
        Level.error,
        'error context',
        error: Exception('fail'),
        stackTrace: StackTrace.current,
      );

      expect(
        () => output.output(OutputEvent(event, ['error context'])),
        returnsNormally,
      );
    });

    test(
      'handles uninitialized Firebase safely when enableInDebug is true',
      () {
        final output = FirebaseCrashlyticsOutput(enableInDebug: true);
        final event = LogEvent(
          Level.error,
          'error context',
          error: Exception('fail'),
          stackTrace: StackTrace.current,
        );

        expect(
          () => output.output(OutputEvent(event, ['error context'])),
          returnsNormally,
        );
      },
    );
  });

  group('top-level log', () {
    test('is a Logger instance', () {
      expect(log, isA<Logger>());
    });

    test('can log debug message without throwing', () {
      expect(() => log.d('test debug'), returnsNormally);
    });

    test('can log info message without throwing', () {
      expect(() => log.i('test info'), returnsNormally);
    });

    test('can log warning message without throwing', () {
      expect(() => log.w('test warning'), returnsNormally);
    });

    test('can log error message without throwing', () {
      expect(() => log.e('test error'), returnsNormally);
    });

    test('can log wtf message without throwing', () {
      expect(() => log.f('test wtf'), returnsNormally);
    });

    test('can log trace message without throwing', () {
      expect(() => log.t('test trace'), returnsNormally);
    });

    test('does not throw with error and stackTrace', () {
      expect(
        () => log.e(
          'error context',
          error: Exception('fail'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
