@Tags(['screenshot'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse_track/core/presentation/theme/app_theme.dart';
import 'package:pulse_track/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';

import 'helpers/screenshot_test_helper.dart';

/// Screenshot integration tests for the multi-step onboarding wizard.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final effectiveLocales = getEffectiveLocales();
  final prefix = getScreenshotPrefix();

  setUpAll(() async {
    await initScreenshotEnvironment(binding);
  });

  group('01_onboarding Screenshot Generator', () {
    for (final localeCode in effectiveLocales) {
      for (final isDark in [false, true]) {
        final themeLabel = isDark ? 'dark' : 'light';
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        final locale = Locale(localeCode);

        testWidgets('Capture 01_onboarding flow [$localeCode] [$themeLabel]', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            buildScreenshotAppWrapper(
              locale: locale,
              isDark: isDark,
              theme: theme,
              themeMode: themeMode,
              overrides: [
                appSettingsProvider.overrideWith(MockAppSettingsNotifier.new),
              ],
              child: const OnboardingScreen(),
            ),
          );

          await tester.pumpAndSettle();

          // 01_welcome
          await binding.takeScreenshot(
            '$prefix$localeCode/01_onboarding/01_welcome_$themeLabel',
          );

          // Step 1 -> Step 2 (Permissions)
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
          await binding.takeScreenshot(
            '$prefix$localeCode/01_onboarding/02_permissions_$themeLabel',
          );

          // Step 2 -> Step 3 (Biometric)
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
          await binding.takeScreenshot(
            '$prefix$localeCode/01_onboarding/03_biometric_$themeLabel',
          );

          // Step 3 -> Step 4 (Completion)
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
          await binding.takeScreenshot(
            '$prefix$localeCode/01_onboarding/04_completion_$themeLabel',
          );
        }, tags: 'screenshot');
      }
    }
  });
}
