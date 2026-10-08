/// Summary metrics calculated for a single time period.
class PeriodMetrics {
  /// Number of completed workout sessions.
  final int sessionCount;

  /// Combined duration of all workouts in this period.
  final Duration totalDuration;

  /// Average heart rate across all sessions in this period.
  final double avgBpm;

  /// Peak heart rate reached across all sessions in this period.
  final int maxBpm;

  const PeriodMetrics({
    required this.sessionCount,
    required this.totalDuration,
    required this.avgBpm,
    required this.maxBpm,
  });

  /// An empty metrics baseline when no sessions occurred in the window.
  static const empty = PeriodMetrics(
    sessionCount: 0,
    totalDuration: Duration.zero,
    avgBpm: 0.0,
    maxBpm: 0,
  );
}

/// Comparison between two adjacent rolling time windows.
class PeriodComparison {
  /// Metrics for the current rolling period.
  final PeriodMetrics current;

  /// Metrics for the immediately preceding rolling period.
  final PeriodMetrics previous;

  /// Difference in workout session count (current minus previous).
  final int sessionCountDelta;

  /// Difference in total training duration (current minus previous).
  final Duration durationDelta;

  /// Difference in average BPM (current minus previous).
  final double avgBpmDelta;

  const PeriodComparison({
    required this.current,
    required this.previous,
    required this.sessionCountDelta,
    required this.durationDelta,
    required this.avgBpmDelta,
  });
}
