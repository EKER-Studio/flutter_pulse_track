import 'package:pulse_track/features/statistics/domain/entities/habits_summary.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Pure domain service calculating workout consistency, streaks, and active day counts.
class HabitsCalculator {
  const HabitsCalculator._();

  /// Calculates the current consecutive days workout streak relative to [now].
  static int calculateStreak(List<WorkoutSession> sessions, [DateTime? now]) {
    if (sessions.isEmpty) return 0;

    final referenceDate = now ?? DateTime.now();
    final dates = sessions
        .map(
          (s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
        )
        .toSet();

    final todayDate = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    if (!dates.contains(todayDate) && !dates.contains(yesterdayDate)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(todayDate) ? todayDate : yesterdayDate;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the best historical consecutive days workout streak.
  static int calculateBestStreak(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;

    final dates =
        sessions
            .map(
              (s) => DateTime(
                s.startTime.year,
                s.startTime.month,
                s.startTime.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    int best = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) {
          best = current;
        }
      } else {
        current = 1;
      }
    }

    return best;
  }

  /// Calculates the count of distinct active workout days in the last 30 days.
  static int calculateActiveDaysInLast30(
    List<WorkoutSession> sessions, [
    DateTime? now,
  ]) {
    if (sessions.isEmpty) return 0;

    final referenceDate = now ?? DateTime.now();
    final windowStart = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).subtract(const Duration(days: 29));

    final dates = sessions
        .map(
          (s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
        )
        .where((d) => !d.isBefore(windowStart))
        .toSet();

    return dates.length;
  }

  /// Calculates a combined [HabitsSummary] for the given sessions.
  static HabitsSummary calculateSummary(
    List<WorkoutSession> sessions, [
    DateTime? now,
  ]) {
    return HabitsSummary(
      currentStreak: calculateStreak(sessions, now),
      bestStreak: calculateBestStreak(sessions),
      activeDaysInLast30: calculateActiveDaysInLast30(sessions, now),
    );
  }
}
