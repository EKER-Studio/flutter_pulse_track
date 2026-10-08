import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/habits_activity_card.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/milestones_card.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/period_comparison_card.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  final session = WorkoutSession(
    id: 1,
    startTime: DateTime(2026, 10, 8, 10),
    endTime: DateTime(2026, 10, 8, 11),
    avgBpm: 140,
    maxBpm: 175,
    bpmSamples: const [130, 140, 150],
    sensorLocationIndex: 0,
    deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
    deviceName: 'Polar H10',
  );

  testWidgets(
    'StatisticsScreen renders period comparison, habits, and milestone cards',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchWorkoutHistoryStreamProvider.overrideWith(
              (ref) => Stream.value([session]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: StatisticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.byType(PeriodComparisonCard), findsOneWidget);
      expect(find.byType(HabitsActivityCard), findsOneWidget);
      expect(find.byType(MilestonesCard), findsOneWidget);
    },
  );
}
