@Tags(['screenshot'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse_track/core/presentation/theme/app_theme.dart';
import 'package:pulse_track/core/presentation/views/route_error_view.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/max_hr_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/theme_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/wipe_data_dialog.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

import 'helpers/screenshot_test_helper.dart';

/// Screenshot integration tests for edge states, error scenarios, and modal dialogs.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final effectiveLocales = getEffectiveLocales();
  final prefix = getScreenshotPrefix();

  setUpAll(() async {
    await initScreenshotEnvironment(binding);
  });

  group('08_states & 09_dialogs Screenshot Generator', () {
    for (final localeCode in effectiveLocales) {
      for (final isDark in [false, true]) {
        final themeLabel = isDark ? 'dark' : 'light';
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        final locale = Locale(localeCode);

        // 08_states / 01_empty_home
        testWidgets(
          'Capture 08_states/01_empty_home [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                overrides: [
                  watchSavedDeviceProfilesStreamProvider.overrideWithValue(
                    const AsyncValue<List<DeviceProfile>>.data([]),
                  ),
                ],
                child: const HrHomeView(),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/08_states/01_empty_home_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 08_states / 02_empty_history
        testWidgets(
          'Capture 08_states/02_empty_history [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                overrides: [
                  watchWorkoutHistoryStreamProvider.overrideWithValue(
                    const AsyncValue<List<WorkoutSession>>.data([]),
                  ),
                ],
                child: const WorkoutHistoryView(),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/08_states/02_empty_history_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 08_states / 03_bluetooth_off
        testWidgets(
          'Capture 08_states/03_bluetooth_off [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                overrides: [
                  bleScannerProvider.overrideWith(
                    () => MockBleScannerNotifier(
                      const BleScannerState.adapterOff(),
                    ),
                  ),
                ],
                child: const HrScannerView(),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/08_states/03_bluetooth_off_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 08_states / 04_monitor_failure
        testWidgets(
          'Capture 08_states/04_monitor_failure [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                overrides: [
                  hrMonitorProvider.overrideWith(
                    () => MockHrMonitorNotifier(
                      const MonitorState.failure(
                        message: 'GATT connection timed out after 4 seconds.',
                      ),
                    ),
                  ),
                ],
                child: const HrMonitorView(
                  deviceId: 'C3:28:84:91:DE:F1',
                  deviceName: 'Polar H10',
                ),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/08_states/04_monitor_failure_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 08_states / 05_route_error
        testWidgets(
          'Capture 08_states/05_route_error [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                child: const RouteErrorView(
                  error: 'Path "/history/details/999" could not be resolved.',
                ),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/08_states/05_route_error_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 09_dialogs / 01_theme_dialog
        testWidgets(
          'Capture 09_dialogs/01_theme_dialog [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                child: Scaffold(
                  body: Center(
                    child: ThemeSelectionDialog(
                      currentMode: isDark
                          ? AppThemeMode.dark
                          : AppThemeMode.light,
                      onSelected: (_) {},
                    ),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/09_dialogs/01_theme_dialog_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 09_dialogs / 02_max_hr_dialog
        testWidgets(
          'Capture 09_dialogs/02_max_hr_dialog [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                child: Scaffold(
                  body: Center(
                    child: MaxHrSelectionDialog(
                      currentMaxHr: 190,
                      onConfirmed: (_) {},
                    ),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/09_dialogs/02_max_hr_dialog_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 09_dialogs / 03_wipe_data_dialog
        testWidgets(
          'Capture 09_dialogs/03_wipe_data_dialog [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                child: const Scaffold(body: Center(child: WipeDataDialog())),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/09_dialogs/03_wipe_data_dialog_$themeLabel',
            );
          },
          tags: 'screenshot',
        );
      }
    }
  });
}
