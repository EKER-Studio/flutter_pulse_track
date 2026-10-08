import 'package:pulse_track/features/statistics/domain/entities/milestone.dart';
import 'package:pulse_track/features/statistics/domain/services/habits_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Pure domain service calculating milestone achievements from workout history.
class MilestoneCalculator {
  const MilestoneCalculator._();

  /// Evaluates and returns all milestones sorted by unlocked status first, then category.
  static List<Milestone> evaluateMilestones(List<WorkoutSession> sessions) {
    final sortedAsc = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final count = sortedAsc.length;
    final bestStreak = HabitsCalculator.calculateBestStreak(sortedAsc);

    // Check endurance sessions
    WorkoutSession? endurance60Session;
    WorkoutSession? endurance90Session;
    WorkoutSession? earlyBirdSession;
    WorkoutSession? nightOwlSession;

    for (final s in sortedAsc) {
      if (s.endTime != null) {
        final durationMin = s.endTime!.difference(s.startTime).inMinutes;
        if (durationMin >= 60 && endurance60Session == null) {
          endurance60Session = s;
        }
        if (durationMin >= 90 && endurance90Session == null) {
          endurance90Session = s;
        }
      }
      if (s.startTime.hour < 7 && earlyBirdSession == null) {
        earlyBirdSession = s;
      }
      if (s.startTime.hour >= 21 && nightOwlSession == null) {
        nightOwlSession = s;
      }
    }

    // Check weekend warrior (Saturday & Sunday in same weekend)
    DateTime? weekendWarriorDate;
    final dates = sortedAsc
        .map(
          (s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
        )
        .toSet();

    for (final date in dates) {
      if (date.weekday == DateTime.saturday) {
        final sunday = date.add(const Duration(days: 1));
        if (dates.contains(sunday)) {
          weekendWarriorDate = sunday;
          break;
        }
      }
    }

    return [
      _createSessionMilestone(
        type: MilestoneType.firstWorkout,
        target: 1,
        actual: count,
        sessions: sortedAsc,
        title: 'First Step',
        description: 'Complete your first workout session',
      ),
      _createSessionMilestone(
        type: MilestoneType.workouts5,
        target: 5,
        actual: count,
        sessions: sortedAsc,
        title: 'High Five',
        description: 'Complete 5 workout sessions',
      ),
      _createSessionMilestone(
        type: MilestoneType.workouts10,
        target: 10,
        actual: count,
        sessions: sortedAsc,
        title: 'Consistent Mover',
        description: 'Complete 10 workout sessions',
      ),
      _createSessionMilestone(
        type: MilestoneType.workouts25,
        target: 25,
        actual: count,
        sessions: sortedAsc,
        title: 'Quarter Century',
        description: 'Complete 25 workout sessions',
      ),
      _createSessionMilestone(
        type: MilestoneType.workouts50,
        target: 50,
        actual: count,
        sessions: sortedAsc,
        title: 'Half Century',
        description: 'Complete 50 workout sessions',
      ),
      _createSessionMilestone(
        type: MilestoneType.workouts100,
        target: 100,
        actual: count,
        sessions: sortedAsc,
        title: 'Century Club',
        description: 'Complete 100 workout sessions',
      ),
      _createStreakMilestone(
        type: MilestoneType.streak3,
        target: 3,
        actualStreak: bestStreak,
        title: 'Streak Starter',
        description: 'Work out 3 days in a row',
      ),
      _createStreakMilestone(
        type: MilestoneType.streak7,
        target: 7,
        actualStreak: bestStreak,
        title: 'Unstoppable Week',
        description: 'Work out 7 days in a row',
      ),
      _createStreakMilestone(
        type: MilestoneType.streak14,
        target: 14,
        actualStreak: bestStreak,
        title: 'Fortnight Champion',
        description: 'Work out 14 days in a row',
      ),
      _createStreakMilestone(
        type: MilestoneType.streak30,
        target: 30,
        actualStreak: bestStreak,
        title: 'Monthly Dedication',
        description: 'Work out 30 days in a row',
      ),
      Milestone(
        type: MilestoneType.endurance60,
        category: MilestoneCategory.endurance,
        title: 'Hour Power',
        description: 'Complete a workout lasting at least 60 minutes',
        isUnlocked: endurance60Session != null,
        unlockedAt: endurance60Session?.startTime,
        progress: endurance60Session != null ? 1.0 : 0.0,
      ),
      Milestone(
        type: MilestoneType.endurance90,
        category: MilestoneCategory.endurance,
        title: 'Iron Will',
        description: 'Complete a workout lasting at least 90 minutes',
        isUnlocked: endurance90Session != null,
        unlockedAt: endurance90Session?.startTime,
        progress: endurance90Session != null ? 1.0 : 0.0,
      ),
      Milestone(
        type: MilestoneType.earlyBird,
        category: MilestoneCategory.special,
        title: 'Early Bird',
        description: 'Start a workout before 7:00 AM',
        isUnlocked: earlyBirdSession != null,
        unlockedAt: earlyBirdSession?.startTime,
        progress: earlyBirdSession != null ? 1.0 : 0.0,
      ),
      Milestone(
        type: MilestoneType.nightOwl,
        category: MilestoneCategory.special,
        title: 'Night Owl',
        description: 'Start a workout after 9:00 PM',
        isUnlocked: nightOwlSession != null,
        unlockedAt: nightOwlSession?.startTime,
        progress: nightOwlSession != null ? 1.0 : 0.0,
      ),
      Milestone(
        type: MilestoneType.weekendWarrior,
        category: MilestoneCategory.special,
        title: 'Weekend Warrior',
        description: 'Work out on both Saturday and Sunday of the same weekend',
        isUnlocked: weekendWarriorDate != null,
        unlockedAt: weekendWarriorDate,
        progress: weekendWarriorDate != null ? 1.0 : 0.0,
      ),
    ];
  }

  static Milestone _createSessionMilestone({
    required MilestoneType type,
    required int target,
    required int actual,
    required List<WorkoutSession> sessions,
    required String title,
    required String description,
  }) {
    final isUnlocked = actual >= target;
    return Milestone(
      type: type,
      category: MilestoneCategory.sessions,
      title: title,
      description: description,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? sessions[target - 1].startTime : null,
      progress: (actual / target).clamp(0.0, 1.0),
    );
  }

  static Milestone _createStreakMilestone({
    required MilestoneType type,
    required int target,
    required int actualStreak,
    required String title,
    required String description,
  }) {
    final isUnlocked = actualStreak >= target;
    return Milestone(
      type: type,
      category: MilestoneCategory.streaks,
      title: title,
      description: description,
      isUnlocked: isUnlocked,
      progress: (actualStreak / target).clamp(0.0, 1.0),
    );
  }
}
