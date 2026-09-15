import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/presentation/theme/app_theme.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  testWidgets('HrHomeView matches visual golden baseline', (
    WidgetTester tester,
  ) async {
    // Configure explicit fixed viewport size and device pixel ratio for deterministic rendering
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSavedDeviceProfilesStreamProvider.overrideWithValue(
            const AsyncValue<List<DeviceProfile>>.data([]),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const HrHomeView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HrHomeView),
      matchesGoldenFile('goldens/hr_home_view.png'),
    );
  }, tags: 'golden');
}
