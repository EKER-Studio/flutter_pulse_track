import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';

void main() {
  group('formatWorkoutDuration', () {
    test('formats minutes only for under an hour', () {
      final start = DateTime(2026, 1, 1, 10);
      final end = DateTime(2026, 1, 1, 10, 45);

      expect(formatWorkoutDuration(start, end), '45m');
    });

    test('formats hours and minutes for over an hour', () {
      final start = DateTime(2026, 1, 1, 10);
      final end = DateTime(2026, 1, 1, 11, 30);

      expect(formatWorkoutDuration(start, end), '1h 30m');
    });

    test('includes seconds when requested', () {
      final start = DateTime(2026, 1, 1, 10);
      final end = DateTime(2026, 1, 1, 10, 15, 42);

      expect(
        formatWorkoutDuration(start, end, includeSeconds: true),
        '15m 42s',
      );
    });

    test('returns inProgressLabel when end is null', () {
      final start = DateTime(2026, 1, 1, 10);

      expect(
        formatWorkoutDuration(start, null, inProgressLabel: 'Active'),
        'Active',
      );
    });
  });

  group('formatAbsoluteDate', () {
    test('formats date with day of week, month, day, year', () {
      final date = DateTime(2026, 10, 13);
      final formatted = formatAbsoluteDate(date);
      expect(formatted, contains('Oct 13, 2026'));
    });
  });
}
