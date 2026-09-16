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

  testWidgets('empty history shows scan CTA and no sensor chips', (
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

    expect(find.text('Scan for New Sensor'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('saved sensors render as connect chips', (
    WidgetTester tester,
  ) async {
    final profiles = [
      DeviceProfile(
        id: 1,
        macAddress: 'AA:BB:CC:DD:EE:01',
        name: 'Polar H10',
        lastConnectedAt: DateTime(2026, 1, 1),
        lastSensorLocationIndex: 1,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSavedDeviceProfilesStreamProvider.overrideWithValue(
            AsyncValue<List<DeviceProfile>>.data(profiles),
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

    expect(find.text('Saved Sensors (Direct Connect)'), findsOneWidget);
    expect(find.text('Polar H10'), findsOneWidget);
  });

  testWidgets('load failure shows retry action', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSavedDeviceProfilesStreamProvider.overrideWithValue(
            AsyncValue<List<DeviceProfile>>.error(
              Exception('db unavailable'),
              StackTrace.empty,
            ),
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

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(HrHomeView), findsOneWidget);
  });
}
