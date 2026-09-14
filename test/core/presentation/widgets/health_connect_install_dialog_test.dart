import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/core/presentation/widgets/health_connect_install_dialog.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

class MockHealthService extends Mock implements HealthService {}

void main() {
  late MockHealthService mockHealthService;

  setUp(() {
    mockHealthService = MockHealthService();
    when(() => mockHealthService.installHealthConnect())
        .thenAnswer((_) async {});
  });

  Widget createWidget({VoidCallback? onStoreClicked}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => HealthConnectInstallDialog.show(
              context,
              healthService: mockHealthService,
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  group('HealthConnectInstallDialog', () {
    testWidgets('renders dialog and dismisses on cancel', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(HealthConnectInstallDialog), findsOneWidget);
      expect(find.text('Health Connect App Required'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(HealthConnectInstallDialog), findsNothing);
      verifyNever(() => mockHealthService.installHealthConnect());
    });

    testWidgets(
      'triggers store action and calls installHealthConnect on confirm',
      (tester) async {
        bool storeClicked = false;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => HealthConnectInstallDialog(
                      healthService: mockHealthService,
                      onStoreClicked: () => storeClicked = true,
                    ),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(HealthConnectInstallDialog), findsOneWidget);

        await tester.tap(find.text('Install from Play Store'));
        await tester.pumpAndSettle();

        expect(find.byType(HealthConnectInstallDialog), findsNothing);
        expect(storeClicked, isTrue);
        verify(() => mockHealthService.installHealthConnect()).called(1);
      },
    );
  });
}
