import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pulse_track/features/settings/presentation/screens/licenses_screen.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  testWidgets('LicensesScreen renders header card with app version and title', (
    WidgetTester tester,
  ) async {
    final packageInfo = PackageInfo(
      appName: 'PulseTrack',
      packageName: 'com.ekerstudio.pulsetrack',
      version: '1.2.3',
      buildNumber: '42',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: LicensesScreen(packageInfo: packageInfo),
      ),
    );

    // Initial pump (FutureBuilder)
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(LicensesScreen), findsOneWidget);
    expect(find.text('PulseTrack'), findsOneWidget);
    expect(find.text('v1.2.3 (42)'), findsOneWidget);
    expect(find.text('© 2026 PulseTrack'), findsOneWidget);
  });
}
