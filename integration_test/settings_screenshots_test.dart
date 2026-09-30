@Tags(['screenshot'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pulse_track/core/presentation/theme/app_theme.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/screens/licenses_screen.dart';
import 'package:pulse_track/features/settings/presentation/screens/settings_screen.dart';

import 'helpers/screenshot_test_helper.dart';

/// Screenshot integration tests for settings and license screens.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final effectiveLocales = getEffectiveLocales();
  final prefix = getScreenshotPrefix();

  setUpAll(() async {
    await initScreenshotEnvironment(binding);
  });

  group('07_settings Screenshot Generator', () {
    for (final localeCode in effectiveLocales) {
      for (final isDark in [false, true]) {
        final themeLabel = isDark ? 'dark' : 'light';
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        final locale = Locale(localeCode);

        // 07_settings / 01_settings_main
        testWidgets(
          'Capture 07_settings/01_settings_main [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                overrides: [
                  appSettingsProvider.overrideWith(
                    () => MockAppSettingsNotifier(
                      UserSettings(
                        themeMode: isDark
                            ? AppThemeMode.dark
                            : AppThemeMode.light,
                        isAnalyticsEnabled: false,
                        isOnboardingCompleted: true,
                      ),
                    ),
                  ),
                ],
                child: const SettingsScreen(),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/07_settings/01_settings_main_$themeLabel',
            );
          },
          tags: 'screenshot',
        );

        // 07_settings / 02_licenses
        testWidgets(
          'Capture 07_settings/02_licenses [$localeCode] [$themeLabel]',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              buildScreenshotAppWrapper(
                locale: locale,
                isDark: isDark,
                theme: theme,
                themeMode: themeMode,
                child: LicensesScreen(
                  packageInfo: PackageInfo(
                    appName: 'PulseTrack',
                    packageName: 'com.ekerstudio.pulsetrack',
                    version: '1.0.0',
                    buildNumber: '1',
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            await binding.takeScreenshot(
              '$prefix$localeCode/07_settings/02_licenses_$themeLabel',
            );
          },
          tags: 'screenshot',
        );
      }
    }
  });
}
