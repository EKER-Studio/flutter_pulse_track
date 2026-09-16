// Widget test for HrScannerView
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

class _MockBluetoothScannerService extends Mock
    implements BluetoothScannerService {}

void main() {
  late _MockBluetoothScannerService mockScannerService;

  setUp(() {
    mockScannerService = _MockBluetoothScannerService();
    when(() => mockScannerService.adapterState)
        .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
    when(() => mockScannerService.scanResults)
        .thenAnswer((_) => Stream.value([]));
    when(() => mockScannerService.isScanningNow).thenReturn(false);
    when(
      () => mockScannerService.startScan(
        withServices: any(named: 'withServices'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockScannerService.stopScan()).thenAnswer((_) async {});
  });

  testWidgets('HrScannerView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bluetoothScannerServiceProvider.overrideWithValue(mockScannerService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HrScannerView(),
        ),
      ),
    );

    expect(find.byType(HrScannerView), findsOneWidget);
  });
}
