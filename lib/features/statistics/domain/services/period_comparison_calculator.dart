import 'package:pulse_track/features/statistics/domain/entities/period_comparison.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Pure domain service computing comparative metrics between rolling workout windows.
class PeriodComparisonCalculator {
  const PeriodComparisonCalculator._();

  /// Compares metrics between the current [days] rolling window and the immediately preceding [days] window.
  static PeriodComparison compareRollingDays({
    required List<WorkoutSession> sessions,
    int days = 7,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final endOfCurrent = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      23,
      59,
      59,
      999,
    );
    final startOfCurrent = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).subtract(Duration(days: days - 1));

    final endOfPrevious = startOfCurrent.subtract(
      const Duration(milliseconds: 1),
    );
    final startOfPrevious = startOfCurrent.subtract(Duration(days: days));

    final currentSessions = sessions.where((s) {
      return !s.startTime.isBefore(startOfCurrent) &&
          !s.startTime.isAfter(endOfCurrent);
    }).toList();

    final previousSessions = sessions.where((s) {
      return !s.startTime.isBefore(startOfPrevious) &&
          !s.startTime.isAfter(endOfPrevious);
    }).toList();

    final currentMetrics = _computeMetrics(currentSessions);
    final previousMetrics = _computeMetrics(previousSessions);

    return PeriodComparison(
      current: currentMetrics,
      previous: previousMetrics,
      sessionCountDelta:
          currentMetrics.sessionCount - previousMetrics.sessionCount,
      durationDelta:
          currentMetrics.totalDuration - previousMetrics.totalDuration,
      avgBpmDelta: currentMetrics.avgBpm - previousMetrics.avgBpm,
    );
  }

  static PeriodMetrics _computeMetrics(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return PeriodMetrics.empty;

    var totalDurationMs = 0;
    var bpmSum = 0;
    var maxBpm = 0;

    for (final session in sessions) {
      final end = session.endTime ?? session.startTime;
      totalDurationMs += end.difference(session.startTime).inMilliseconds;
      bpmSum += session.avgBpm;
      if (session.maxBpm > maxBpm) {
        maxBpm = session.maxBpm;
      }
    }

    return PeriodMetrics(
      sessionCount: sessions.length,
      totalDuration: Duration(milliseconds: totalDurationMs),
      avgBpm: bpmSum / sessions.length,
      maxBpm: maxBpm,
    );
  }
}
