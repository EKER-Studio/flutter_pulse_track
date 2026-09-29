import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/screens/settings_screen.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/max_hr_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/theme_selection_dialog.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

class FakeAppSettingsNotifier extends AppSettingsNotifier {
  final UserSettings _initial;

  FakeAppSettingsNotifier([this._initial = const UserSettings()]);

  @override
  UserSettings build() => _initial;

  @override
  Future<void> updateTheme(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
  }

  @override
  Future<void> updateMaxHr(int maxHr) async {
    state = state.copyWith(defaultMaxHr: maxHr);
  }
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'PulseTrack',
      packageName: 'com.ekerstudio.pulsetrack',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget buildSubject({UserSettings settings = const UserSettings()}) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(
          () => FakeAppSettingsNotifier(settings),
        ),
        watchWorkoutHistoryStreamProvider.overrideWith(
          (ref) => Stream<List<WorkoutSession>>.value([]),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders all section headers and core settings tiles', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('WORKOUT & METRICS'), findsOneWidget);
      expect(find.text('DATA MANAGEMENT'), findsOneWidget);
      expect(find.text('PRIVACY & DIAGNOSTICS'), findsOneWidget);
      expect(find.text('ABOUT & SUPPORT'), findsOneWidget);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Max Heart Rate'), findsOneWidget);
      expect(
        find.text('190 BPM (Heart rate zones calculation)'),
        findsOneWidget,
      );
      expect(find.text('Export All Workouts'), findsOneWidget);
      expect(find.text('Import Workouts'), findsOneWidget);
      expect(find.text('Wipe All Workouts'), findsOneWidget);
      expect(find.text('Crash Reports'), findsOneWidget);
      expect(find.text('Usage Analytics'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Rate PulseTrack'), findsOneWidget);
      expect(find.text('Licenses'), findsOneWidget);
    });

    testWidgets('tapping Theme tile opens ThemeSelectionDialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.byType(ThemeSelectionDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ThemeSelectionDialog),
          matching: find.text('System default'),
        ),
        findsOneWidget,
      );
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Max Heart Rate tile opens MaxHrSelectionDialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Max Heart Rate'));
      await tester.pumpAndSettle();

      expect(find.byType(MaxHrSelectionDialog), findsOneWidget);
      expect(find.text('Set Max Heart Rate'), findsOneWidget);
    });
  });
}
