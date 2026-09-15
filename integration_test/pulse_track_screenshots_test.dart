import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';

import 'helpers/screenshot_test_helper.dart';

/// Integration test suite that generates pixel-perfect store screenshots for Google Play Store.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final effectiveLocales = getEffectiveLocales();
  final prefix = getScreenshotPrefix();

  final mockProfiles = generateMockSavedProfiles();
  final mockDevices = generateMockScannerDevices();
  final mockMeasurement = generateMockLiveMeasurement();
  final mockSessions = generateMockWorkoutSessions();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  group('Google Play Store Screenshot Suite', () {
    for (final localeCode in effectiveLocales) {
      final locale = Locale(localeCode);

      // -----------------------------------------------------------------------
      // 01. Home Dashboard View (Saved Sensors & Feature Hub)
      // -----------------------------------------------------------------------
      testWidgets('Capture 01_home [$localeCode]', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildScreenshotAppWrapper(
            locale: locale,
            overrides: [
              watchSavedDeviceProfilesStreamProvider.overrideWithValue(
                AsyncValue<List<DeviceProfile>>.data(mockProfiles),
              ),
            ],
            child: const HrHomeView(),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await binding.takeScreenshot('$prefix$localeCode/01_home_dark');
      }, tags: 'screenshot');

      // -----------------------------------------------------------------------
      // 02. BLE Scanner View (Discovered Heart Rate Sensors)
      // -----------------------------------------------------------------------
      testWidgets('Capture 02_scanner [$localeCode]', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildScreenshotAppWrapper(
            locale: locale,
            overrides: [
              bleScannerProvider.overrideWith(
                () => MockBleScannerNotifier(
                  BleScannerState.scanning(devices: mockDevices),
                ),
              ),
            ],
            child: const HrScannerView(),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await binding.takeScreenshot('$prefix$localeCode/02_scanner_dark');
      }, tags: 'screenshot');

      // -----------------------------------------------------------------------
      // 03. Live HR Monitor View (Active Workout Telemetry)
      // -----------------------------------------------------------------------
      testWidgets('Capture 03_live_monitor [$localeCode]', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildScreenshotAppWrapper(
            locale: locale,
            overrides: [
              hrMonitorProvider.overrideWith(
                () => MockHrMonitorNotifier(
                  MonitorState.connected(measurement: mockMeasurement),
                ),
              ),
            ],
            child: const HrMonitorView(
              deviceId: 'C3:28:84:91:DE:F1',
              deviceName: 'Polar H10',
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await binding.takeScreenshot('$prefix$localeCode/03_live_monitor_dark');
      }, tags: 'screenshot');

      // -----------------------------------------------------------------------
      // 04. Workout History View (Chronological Sessions List)
      // -----------------------------------------------------------------------
      testWidgets('Capture 04_workout_history [$localeCode]', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildScreenshotAppWrapper(
            locale: locale,
            overrides: [
              watchWorkoutHistoryStreamProvider.overrideWithValue(
                AsyncValue<List<WorkoutSession>>.data(mockSessions),
              ),
            ],
            child: const WorkoutHistoryView(),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await binding.takeScreenshot(
          '$prefix$localeCode/04_workout_history_dark',
        );
      }, tags: 'screenshot');

      // -----------------------------------------------------------------------
      // 05. Workout Details View (Telemetry Analytics & HR Zone Waveform)
      // -----------------------------------------------------------------------
      testWidgets('Capture 05_workout_details [$localeCode]', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildScreenshotAppWrapper(
            locale: locale,
            child: WorkoutDetailsView(session: mockSessions.first),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await binding.takeScreenshot(
          '$prefix$localeCode/05_workout_details_dark',
        );
      }, tags: 'screenshot');
    }
  });
}
