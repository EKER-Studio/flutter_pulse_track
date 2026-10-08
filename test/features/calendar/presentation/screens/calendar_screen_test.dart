import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/sections/calendar_month_card.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/sections/calendar_selected_day_section.dart';
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

  testWidgets('CalendarScreen renders month card and selected day section', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchWorkoutHistoryStreamProvider.overrideWith(
            (ref) => Stream.value([session]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CalendarScreen(initialDate: DateTime(2026, 10, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(find.byType(CalendarMonthCard), findsOneWidget);
    expect(find.byType(CalendarSelectedDaySection), findsOneWidget);
    expect(find.textContaining('Polar H10'), findsOneWidget);
  });
}
