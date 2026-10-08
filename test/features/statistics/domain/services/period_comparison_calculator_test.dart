import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/statistics/domain/services/period_comparison_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

void main() {
  WorkoutSession createSession({
    required int id,
    required DateTime start,
    required DateTime end,
    required int avgBpm,
    required int maxBpm,
  }) {
    return WorkoutSession(
      id: id,
      startTime: start,
      endTime: end,
      avgBpm: avgBpm,
      maxBpm: maxBpm,
      bpmSamples: [avgBpm, maxBpm],
      sensorLocationIndex: 0,
      deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
      deviceName: 'Polar H10',
    );
  }

  group('PeriodComparisonCalculator', () {
    final now = DateTime(2026, 10, 8, 12);

    test('returns empty comparison when sessions list is empty', () {
      final result = PeriodComparisonCalculator.compareRollingDays(
        sessions: const [],
        now: now,
      );

      expect(result.current.sessionCount, 0);
      expect(result.previous.sessionCount, 0);
      expect(result.sessionCountDelta, 0);
      expect(result.durationDelta, Duration.zero);
      expect(result.avgBpmDelta, 0.0);
    });

    test('correctly splits current vs previous 7-day windows', () {
      final currentSession = createSession(
        id: 1,
        start: DateTime(2026, 10, 7, 10),
        end: DateTime(2026, 10, 7, 11),
        avgBpm: 140,
        maxBpm: 170,
      );

      final previousSession = createSession(
        id: 2,
        start: DateTime(2026, 9, 28, 10),
        end: DateTime(2026, 9, 28, 10, 30),
        avgBpm: 130,
        maxBpm: 160,
      );

      final olderSession = createSession(
        id: 3,
        start: DateTime(2026, 9, 15, 10),
        end: DateTime(2026, 9, 15, 11),
        avgBpm: 120,
        maxBpm: 150,
      );

      final result = PeriodComparisonCalculator.compareRollingDays(
        sessions: [currentSession, previousSession, olderSession],
        now: now,
      );

      expect(result.current.sessionCount, 1);
      expect(result.previous.sessionCount, 1);
      expect(result.sessionCountDelta, 0);
      expect(result.current.totalDuration, const Duration(hours: 1));
      expect(result.previous.totalDuration, const Duration(minutes: 30));
      expect(result.durationDelta, const Duration(minutes: 30));
      expect(result.avgBpmDelta, 10.0);
    });
  });
}
