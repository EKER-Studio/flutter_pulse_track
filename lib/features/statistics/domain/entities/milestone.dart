/// Grouping categories for workout milestones.
enum MilestoneCategory {
  /// Volume and workout frequency achievements.
  sessions,

  /// Consistency and daily streak achievements.
  streaks,

  /// Long workout endurance achievements.
  endurance,

  /// Time-of-day and routine milestones.
  special,
}

/// Identifiers for specific workout milestones.
enum MilestoneType {
  /// First completed workout session.
  firstWorkout,

  /// 5 completed workout sessions.
  workouts5,

  /// 10 completed workout sessions.
  workouts10,

  /// 25 completed workout sessions.
  workouts25,

  /// 50 completed workout sessions.
  workouts50,

  /// 100 completed workout sessions.
  workouts100,

  /// 3 consecutive days with workouts.
  streak3,

  /// 7 consecutive days with workouts.
  streak7,

  /// 14 consecutive days with workouts.
  streak14,

  /// 30 consecutive days with workouts.
  streak30,

  /// Completed a workout lasting at least 60 minutes.
  endurance60,

  /// Completed a workout lasting at least 90 minutes.
  endurance90,

  /// Workout started before 7:00 AM.
  earlyBird,

  /// Workout started after 9:00 PM.
  nightOwl,

  /// Completed workouts on both Saturday and Sunday in the same weekend.
  weekendWarrior,
}

/// Domain model representing a workout milestone or achievement badge.
class Milestone {
  /// Unique identifier of the milestone.
  final MilestoneType type;

  /// High-level category grouping this milestone.
  final MilestoneCategory category;

  /// Display title of the milestone.
  final String title;

  /// Descriptive requirement text.
  final String description;

  /// Whether the user has met the requirement.
  final bool isUnlocked;

  /// Timestamp when this milestone was unlocked, or `null` if locked.
  final DateTime? unlockedAt;

  /// Progress towards achieving the milestone in range `0.0` to `1.0`.
  final double progress;

  const Milestone({
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.unlockedAt,
    this.progress = 0.0,
  });
}
