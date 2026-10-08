import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/statistics/domain/entities/milestone.dart';
import 'package:pulse_track/features/statistics/domain/services/milestone_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

void main() {
  WorkoutSession createSession({
    required int id,
    required DateTime start,
    required Duration duration,
  }) {
    return WorkoutSession(
      id: id,
      startTime: start,
      endTime: start.add(duration),
      avgBpm: 140,
      maxBpm: 170,
      bpmSamples: const [140, 170],
      sensorLocationIndex: 0,
      deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
      deviceName: 'Polar H10',
    );
  }

  group('MilestoneCalculator', () {
    test('all milestones are locked for empty sessions', () {
      final milestones = MilestoneCalculator.evaluateMilestones(const []);
      expect(milestones.every((m) => !m.isUnlocked), isTrue);
    });

    test('unlocks firstWorkout when 1 session exists', () {
      final sessions = [
        createSession(
          id: 1,
          start: DateTime(2026, 10, 8, 10),
          duration: const Duration(minutes: 30),
        ),
      ];

      final milestones = MilestoneCalculator.evaluateMilestones(sessions);
      final first = milestones.firstWhere(
        (m) => m.type == MilestoneType.firstWorkout,
      );

      expect(first.isUnlocked, isTrue);
      expect(first.unlockedAt, DateTime(2026, 10, 8, 10));
    });

    test(
      'unlocks endurance60 and earlyBird milestones when conditions met',
      () {
        final sessions = [
          createSession(
            id: 1,
            start: DateTime(2026, 10, 8, 6), // 6:00 AM -> early bird!
            duration: const Duration(minutes: 65), // 65 min -> endurance60!
          ),
        ];

        final milestones = MilestoneCalculator.evaluateMilestones(sessions);

        final endurance = milestones.firstWhere(
          (m) => m.type == MilestoneType.endurance60,
        );
        final earlyBird = milestones.firstWhere(
          (m) => m.type == MilestoneType.earlyBird,
        );

        expect(endurance.isUnlocked, isTrue);
        expect(earlyBird.isUnlocked, isTrue);
      },
    );
  });
}
