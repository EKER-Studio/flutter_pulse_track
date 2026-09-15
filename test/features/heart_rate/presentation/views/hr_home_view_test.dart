// Widget test for HrHomeView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';

void main() {
  testWidgets('HrHomeView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSavedDeviceProfilesStreamProvider.overrideWithValue(
            const AsyncValue<List<DeviceProfile>>.data([]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HrHomeView(),
        ),
      ),
    );

    expect(find.byType(HrHomeView), findsOneWidget);
  });
}
