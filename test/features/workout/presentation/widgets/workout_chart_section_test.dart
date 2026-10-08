import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/widgets/workout_chart_section.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  final sessionWithSamples = WorkoutSession(
    id: 1,
    startTime: DateTime(2026, 10, 8, 10),
    endTime: DateTime(2026, 10, 8, 10, 30),
    avgBpm: 140,
    maxBpm: 175,
    bpmSamples: const [120, 130, 140, 150, 160, 170, 175],
    sensorLocationIndex: 0,
    deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
    deviceName: 'Polar H10',
  );

  Widget createWidgetUnderTest(WorkoutSession session) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: WorkoutChartSection(session: session),
          ),
        ),
      ),
    );
  }

  testWidgets('renders waveform chart and HR zone legend', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(sessionWithSamples));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutChartSection), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('scrubbing on chart shows floating BPM indicator', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(sessionWithSamples));
    await tester.pumpAndSettle();

    final chartGesture = find.byType(GestureDetector);
    expect(chartGesture, findsOneWidget);

    // Pan across chart to trigger scrub
    final gesture = await tester.startGesture(tester.getCenter(chartGesture));
    await tester.pump();

    // Verify HUD indicator with BPM is displayed
    expect(find.textContaining('BPM'), findsWidgets);

    // End gesture to clear scrub HUD
    await gesture.up();
    await tester.pumpAndSettle();

    // After gesture up, scrub HUD is dismissed
    expect(find.textContaining('+'), findsNothing);
  });
}
