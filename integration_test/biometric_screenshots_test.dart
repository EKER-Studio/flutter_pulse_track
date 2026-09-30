@Tags(['screenshot'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse_track/core/presentation/screens/biometric_shield_screen.dart';
import 'package:pulse_track/core/presentation/theme/app_theme.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';

import 'helpers/screenshot_test_helper.dart';

/// Screenshot integration tests for the biometric shield security screen.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final effectiveLocales = getEffectiveLocales();
  final prefix = getScreenshotPrefix();

  setUpAll(() async {
    await initScreenshotEnvironment(binding);
  });

  group('06_biometric Screenshot Generator', () {
    for (final localeCode in effectiveLocales) {
      for (final isDark in [false, true]) {
        final themeLabel = isDark ? 'dark' : 'light';
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        final locale = Locale(localeCode);

        // 06_biometric / 01_biometric_lock
        testWidgets(
          'Capture 06_biometric/01_biometric_lock [$localeCode] [$themeLabel]',
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
                      const UserSettings(
                        isBiometricLockEnabled: true,
                        isLocked: true,
                      ),
                    ),
                  ),
                ],
                child: const BiometricShieldScreen(),
              ),
            );

            await tester.pumpAndSettle();

            await binding.takeScreenshot(
              '$prefix$localeCode/06_biometric/01_biometric_lock_$themeLabel',
            );
          },
          tags: 'screenshot',
        );
      }
    }
  });
}
