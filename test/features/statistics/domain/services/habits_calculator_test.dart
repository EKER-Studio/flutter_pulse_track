import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/statistics/domain/services/habits_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

void main() {
  WorkoutSession createSession(DateTime start) {
    return WorkoutSession(
      id: start.millisecondsSinceEpoch,
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
      avgBpm: 140,
      maxBpm: 165,
      bpmSamples: const [140, 165],
      sensorLocationIndex: 0,
      deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
      deviceName: 'Polar H10',
    );
  }

  group('HabitsCalculator', () {
    final now = DateTime(2026, 10, 8, 12);

    test('returns 0 streak when sessions list is empty', () {
      expect(HabitsCalculator.calculateStreak(const [], now), 0);
      expect(HabitsCalculator.calculateBestStreak(const []), 0);
      expect(HabitsCalculator.calculateActiveDaysInLast30(const [], now), 0);
    });

    test('calculates active streak up to today or yesterday', () {
      final sessions = [
        createSession(DateTime(2026, 10, 8, 8)),
        createSession(DateTime(2026, 10, 7, 18)),
        createSession(DateTime(2026, 10, 6, 7)),
        createSession(DateTime(2026, 10, 4, 12)), // Break on Oct 5
      ];

      expect(HabitsCalculator.calculateStreak(sessions, now), 3);
      expect(HabitsCalculator.calculateBestStreak(sessions), 3);
      expect(HabitsCalculator.calculateActiveDaysInLast30(sessions, now), 4);
    });

    test('calculates historical best streak longer than current streak', () {
      final sessions = [
        createSession(DateTime(2026, 10, 8, 8)), // Current streak 1
        createSession(DateTime(2026, 9, 20, 8)), // Past 4-day streak:
        createSession(DateTime(2026, 9, 21, 8)),
        createSession(DateTime(2026, 9, 22, 8)),
        createSession(DateTime(2026, 9, 23, 8)),
      ];

      expect(HabitsCalculator.calculateStreak(sessions, now), 1);
      expect(HabitsCalculator.calculateBestStreak(sessions), 4);
    });
  });
}
