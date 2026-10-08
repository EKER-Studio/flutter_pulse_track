import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_day_cell.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_grid.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

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
    'CalendarGrid renders day cells for month and highlights selected date',
    (tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarGrid(
              focusedMonth: DateTime(2026, 10),
              selectedDate: DateTime(2026, 10, 8),
              sessions: [session],
              onDaySelected: (date) => selected = date,
            ),
          ),
        ),
      );

      // Should find cells for days
      expect(find.byType(CalendarDayCell), findsWidgets);
      expect(find.text('8'), findsOneWidget);

      // Tap day 15
      await tester.tap(find.text('15'));
      await tester.pump();

      expect(selected, DateTime(2026, 10, 15));
    },
  );
}
