/// Domain entity summarizing workout habits and streaks.
class HabitsSummary {
  /// Current consecutive days workout streak relative to reference date.
  final int currentStreak;

  /// Longest historical consecutive days workout streak.
  final int bestStreak;

  /// Count of active days with at least one workout in the last 30 days.
  final int activeDaysInLast30;

  const HabitsSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDaysInLast30,
  });

  /// Empty habits baseline when no workout history exists.
  static const empty = HabitsSummary(
    currentStreak: 0,
    bestStreak: 0,
    activeDaysInLast30: 0,
  );
}
