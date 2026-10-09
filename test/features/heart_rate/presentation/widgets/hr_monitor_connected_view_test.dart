import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/animated_heart_icon.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/live_bpm_chart.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/hr_monitor_connected_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

Widget _buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

HrMeasurement _createMeasurement({
  required int bpm,
  List<double> rrIntervals = const [],
  DateTime? timestamp,
  BodySensorLocation sensorLocation = BodySensorLocation.unknown,
  int? batteryLevel,
  bool sensorContactSupported = false,
  bool? sensorContactActive,
  int? energyExpended,
}) {
  return HrMeasurement(
    bpm: bpm,
    rrIntervals: rrIntervals,
    timestamp: timestamp ?? DateTime(2026),
    sensorLocation: sensorLocation,
    batteryLevel: batteryLevel,
    sensorContactSupported: sensorContactSupported,
    sensorContactActive: sensorContactActive,
    energyExpended: energyExpended,
  );
}

void main() {
  testWidgets('renders animated heart icon and BPM live metric', (
    WidgetTester tester,
  ) async {
    final measurement = _createMeasurement(
      bpm: 78,
      sensorContactSupported: true,
      sensorContactActive: true,
      energyExpended: 120,
      sensorLocation: BodySensorLocation.chest,
      batteryLevel: 90,
    );

    await tester.pumpWidget(
      _buildTestWidget(
        HrMonitorConnectedView(
          metric: measurement,
          recentBpmHistory: const [75, 76, 78],
        ),
      ),
    );

    expect(find.byType(AnimatedHeartIcon), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);
    expect(find.byType(LiveBpmChart), findsOneWidget);
    expect(find.text('Detected'), findsOneWidget);
    expect(find.text('120 kJ'), findsOneWidget);
  });

  testWidgets(
    'renders skin contact as lost when sensorContactActive is false',
    (WidgetTester tester) async {
      final measurement = _createMeasurement(
        bpm: 65,
        sensorContactSupported: true,
        sensorContactActive: false,
        sensorLocation: BodySensorLocation.wrist,
      );

      await tester.pumpWidget(
        _buildTestWidget(
          HrMonitorConnectedView(
            metric: measurement,
            recentBpmHistory: const [65],
          ),
        ),
      );

      expect(find.text('Poor contact / No contact'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    },
  );

  testWidgets(
    'renders skin contact as unsupported when sensorContactActive is null',
    (WidgetTester tester) async {
      final measurement = _createMeasurement(bpm: 70);

      await tester.pumpWidget(
        _buildTestWidget(HrMonitorConnectedView(metric: measurement)),
      );

      expect(find.text('Not supported'), findsOneWidget);
    },
  );

  testWidgets('triggers onToggleChartZoom when zoom button is tapped', (
    WidgetTester tester,
  ) async {
    var zoomTapped = false;
    final measurement = _createMeasurement(bpm: 80, sensorContactActive: true);

    await tester.pumpWidget(
      _buildTestWidget(
        HrMonitorConnectedView(
          metric: measurement,
          recentBpmHistory: const [78, 80],
          onToggleChartZoom: () {
            zoomTapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.zoom_in));
    expect(zoomTapped, isTrue);
  });
}
