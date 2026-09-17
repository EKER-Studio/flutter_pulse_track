import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockBluetoothScannerService extends Mock
    implements BluetoothScannerService {}

class _MockBluetoothDevice extends Mock implements BluetoothDevice {}

// ── Helpers ────────────────────────────────────────────────────────────────

final _kHrServiceUuid = Guid('180d');
const _kHardScanTimeout = Duration(seconds: 15);

ScanResult _makeScanResult({
  String deviceId = 'AA:BB:CC:DD:EE:01',
  String deviceName = 'Test HR Sensor',
  int rssi = -50,
}) {
  final device = _MockBluetoothDevice();
  when(() => device.remoteId).thenReturn(DeviceIdentifier(deviceId));
  when(() => device.platformName).thenReturn(deviceName);
  return ScanResult(
    device: device,
    advertisementData: AdvertisementData(
      advName: deviceName,
      txPowerLevel: null,
      appearance: null,
      connectable: true,
      manufacturerData: {},
      serviceData: {},
      serviceUuids: [],
    ),
    rssi: rssi,
    timeStamp: DateTime.now(),
  );
}

ProviderContainer createContainer({BluetoothScannerService? scannerService}) {
  return ProviderContainer(
    overrides: [
      if (scannerService != null)
        bluetoothScannerServiceProvider.overrideWithValue(scannerService),
    ],
  );
}

/// Sets up a mocked [BluetoothScannerService] with controllable streams.
({
  _MockBluetoothScannerService service,
  StreamController<BluetoothAdapterState> adapterStateController,
  StreamController<List<ScanResult>> scanResultsController,
})
buildMockService({bool isScanningNow = false}) {
  final service = _MockBluetoothScannerService();
  final adapterStateController =
      StreamController<BluetoothAdapterState>.broadcast();
  final scanResultsController = StreamController<List<ScanResult>>.broadcast();
  addTearDown(() async {
    if (!adapterStateController.isClosed) {
      await adapterStateController.close();
    }
    if (!scanResultsController.isClosed) {
      await scanResultsController.close();
    }
  });
  when(() => service.adapterState)
      .thenAnswer((_) => adapterStateController.stream);
  when(() => service.scanResults)
      .thenAnswer((_) => scanResultsController.stream);
  when(() => service.isScanningNow).thenReturn(isScanningNow);
  when(
    () => service.startScan(
      withServices: any(named: 'withServices'),
      timeout: any(named: 'timeout'),
    ),
  ).thenAnswer((_) async {});
  when(() => service.stopScan()).thenAnswer((_) => Future.value());
  return (
    service: service,
    adapterStateController: adapterStateController,
    scanResultsController: scanResultsController,
  );
}

/// Reads the [bleScannerProvider] to trigger lazy [build()] and returns the
/// notifier. All tests that interact with the notifier MUST call this before
/// driving streams, so the internal subscriptions are registered.
///
/// Holds a subscription like the scanner view's `watch` does, so the
/// auto-dispose provider stays alive for the test duration instead of
/// being torn down immediately after the synchronous read.
BleScannerNotifier initNotifier(ProviderContainer c) {
  c.listen<BleScannerState>(bleScannerProvider, (_, _) {});
  return c.read(bleScannerProvider.notifier);
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer? container;

  setUp(() {
    resetMocktailState();
  });

  tearDown(() {
    container?.dispose();
  });

  group('initial state', () {
    test('build() returns IdleScannerState', () {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });
  });

  group('startScan()', () {
    test(
      'happy path transitions to ScanningScannerState with empty devices',
      () async {
        final m = buildMockService();
        container = createContainer(scannerService: m.service);
        final notifier = initNotifier(container!);

        await notifier.startScan();

        verify(
          () => m.service.startScan(
            withServices: [_kHrServiceUuid],
            timeout: _kHardScanTimeout,
          ),
        ).called(1);
        final state = container!.read(bleScannerProvider);
        expect(state, isA<ScanningScannerState>());
        expect((state as ScanningScannerState).devices, isEmpty);
      },
    );

    test('skipped when adapter is off', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      initNotifier(container!);

      // Drive adapter off
      m.adapterStateController.add(BluetoothAdapterState.off);
      await Future.delayed(Duration.zero);

      final notifier = container!.read(bleScannerProvider.notifier);
      await notifier.startScan();

      verifyNever(
        () => m.service.startScan(
          withServices: any(named: 'withServices'),
          timeout: any(named: 'timeout'),
        ),
      );
      final state = container!.read(bleScannerProvider);
      expect(state, isA<AdapterOffScannerState>());
    });

    test('skipped when scan already in progress', () async {
      final m = buildMockService(isScanningNow: true);
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      verifyNever(
        () => m.service.startScan(
          withServices: any(named: 'withServices'),
          timeout: any(named: 'timeout'),
        ),
      );
    });

    test('startScan failure transitions to FailureScannerState', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      when(
        () => m.service.startScan(
          withServices: any(named: 'withServices'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(Exception('BLE scan error'));

      await notifier.startScan();

      final state = container!.read(bleScannerProvider);
      expect(state, isA<FailureScannerState>());
      expect(
        (state as FailureScannerState).message,
        contains('BLE scan error'),
      );
    });

    test(
      'scan results stream error transitions to FailureScannerState',
      () async {
        final m = buildMockService();
        container = createContainer(scannerService: m.service);
        final notifier = initNotifier(container!);

        await notifier.startScan();

        m.scanResultsController.addError(Exception('stream error'));
        await Future.delayed(Duration.zero);

        final state = container!.read(bleScannerProvider);
        expect(state, isA<FailureScannerState>());
      },
    );

    test('subsequent scan results ignored after startScan failure', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      when(
        () => m.service.startScan(
          withServices: any(named: 'withServices'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(Exception('fail'));

      await notifier.startScan();

      m.scanResultsController.add([
        _makeScanResult(deviceName: 'ShouldNotAppear'),
      ]);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<FailureScannerState>());
    });
  });

  group('stopScan()', () {
    test('stops scan and transitions to idle when scanning', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();
      await notifier.stopScan();

      verify(() => m.service.stopScan()).called(1);
      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });

    test('transitions to idle when in empty state', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      FakeAsync().run((async) {
        unawaited(notifier.startScan());
        async.elapse(const Duration(milliseconds: 1));
        async.elapse(const Duration(seconds: 6));

        var state = container!.read(bleScannerProvider);
        expect(state, isA<EmptyScannerState>());
      });

      await notifier.stopScan();

      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });

    test('no state change when already idle', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.stopScan();

      verify(() => m.service.stopScan()).called(1);
      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });
  });

  group('retry()', () {
    test('calls stopScan then startScan', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();
      await notifier.retry();

      verify(() => m.service.stopScan()).called(1);
      verify(
        () => m.service.startScan(
          withServices: [_kHrServiceUuid],
          timeout: _kHardScanTimeout,
        ),
      ).called(2);
      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
    });
  });

  group('toggleFilters()', () {
    test('toggle filters and reprocesses last raw results', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      final filteredDevice = _makeScanResult(
        deviceId: 'AA:BB:CC:DD:EE:99',
        deviceName: '',
      );
      m.scanResultsController.add([filteredDevice]);
      await Future.delayed(Duration.zero);

      // With filters enabled, empty-name device is excluded → no qualified devices
      var state = container!.read(bleScannerProvider);
      if (state is ScanningScannerState) {
        expect(state.devices, isEmpty);
      }

      // Toggle filters off — should reprocess and now include the device
      notifier.toggleFilters();
      await Future.delayed(Duration.zero);

      state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
      final scanning = state as ScanningScannerState;
      expect(scanning.devices, hasLength(1));
      expect(scanning.devices[0].id, 'AA:BB:CC:DD:EE:99');
      expect(scanning.devices[0].name, 'Unknown Device');
    });

    test('toggle does nothing when no raw results exist', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      notifier.toggleFilters();
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
    });
  });

  group('adapter state', () {
    test('off transitions to AdapterOffScannerState', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      initNotifier(container!);

      m.adapterStateController.add(BluetoothAdapterState.off);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<AdapterOffScannerState>());
    });

    test('on from adapterOff transitions to idle', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      initNotifier(container!);

      m.adapterStateController.add(BluetoothAdapterState.off);
      await Future.delayed(Duration.zero);
      expect(
        container!.read(bleScannerProvider),
        isA<AdapterOffScannerState>(),
      );

      m.adapterStateController.add(BluetoothAdapterState.on);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });

    test('on from idle does not change state', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      initNotifier(container!);

      m.adapterStateController.add(BluetoothAdapterState.on);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<IdleScannerState>());
    });
  });

  group('scan results filtering', () {
    test('devices with non-empty names and good RSSI pass through', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      final device1 = _makeScanResult(deviceName: 'Sensor A');
      final device2 = _makeScanResult(
        deviceId: 'AA:BB:CC:DD:EE:02',
        deviceName: 'Sensor B',
        rssi: -40,
      );
      m.scanResultsController.add([device1, device2]);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
      final devices = (state as ScanningScannerState).devices;
      expect(devices, hasLength(2));
      expect(devices[0].name, 'Sensor A');
      expect(devices[1].name, 'Sensor B');
    });

    test('empty name devices are excluded when filters enabled', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      final namedDevice = _makeScanResult(deviceName: 'Valid Sensor');
      final unnamedDevice = _makeScanResult(
        deviceId: 'AA:BB:CC:DD:EE:02',
        deviceName: '',
      );
      m.scanResultsController.add([namedDevice, unnamedDevice]);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
      final devices = (state as ScanningScannerState).devices;
      expect(devices, hasLength(1));
      expect(devices[0].id, 'AA:BB:CC:DD:EE:01');
    });

    test(
      'devices below RSSI threshold are excluded when filters enabled',
      () async {
        final m = buildMockService();
        container = createContainer(scannerService: m.service);
        final notifier = initNotifier(container!);

        await notifier.startScan();

        final strongDevice = _makeScanResult(deviceName: 'Strong', rssi: -60);
        final weakDevice = _makeScanResult(
          deviceId: 'AA:BB:CC:DD:EE:02',
          deviceName: 'Weak',
          rssi: -70,
        );
        m.scanResultsController.add([strongDevice, weakDevice]);
        await Future.delayed(Duration.zero);

        final state = container!.read(bleScannerProvider);
        expect(state, isA<ScanningScannerState>());
        final devices = (state as ScanningScannerState).devices;
        expect(devices, hasLength(1));
        expect(devices[0].id, 'AA:BB:CC:DD:EE:01');
      },
    );

    test('deduplicates by device ID keeping last occurrence', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      final first = _makeScanResult(deviceName: 'Dup', rssi: -60);
      final second = _makeScanResult(deviceName: 'Dup', rssi: -45);
      m.scanResultsController.add([first, second]);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
      final devices = (state as ScanningScannerState).devices;
      expect(devices, hasLength(1));
      expect(devices[0].rssi, -45);
    });

    test('no qualified devices keeps scanning state with empty list', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      m.scanResultsController.add([_makeScanResult(deviceName: '')]);
      await Future.delayed(Duration.zero);

      final state = container!.read(bleScannerProvider);
      expect(state, isA<ScanningScannerState>());
      expect((state as ScanningScannerState).devices, isEmpty);
    });

    test(
      'empty state window elapsed transitions to EmptyScannerState',
      () async {
        final m = buildMockService();
        container = createContainer(scannerService: m.service);
        final notifier = initNotifier(container!);

        FakeAsync().run((async) {
          unawaited(notifier.startScan());
          async.elapse(const Duration(milliseconds: 1));
          async.elapse(const Duration(seconds: 6));

          final state = container!.read(bleScannerProvider);
          expect(state, isA<EmptyScannerState>());
        });
      },
    );

    test('qualified devices arriving before empty timer cancel it', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      FakeAsync().run((async) {
        async.elapse(const Duration(seconds: 3));

        m.scanResultsController.add([_makeScanResult()]);
        async.elapse(Duration.zero);

        var state = container!.read(bleScannerProvider);
        expect(state, isA<ScanningScannerState>());
        expect((state as ScanningScannerState).devices, hasLength(1));

        // Elapse past the 6s window — should NOT become EmptyScannerState
        async.elapse(const Duration(seconds: 4));
        final afterState = container!.read(bleScannerProvider);
        expect(afterState, isA<ScanningScannerState>());
      });
    });
  });

  group('cleanup on dispose', () {
    test('cancels subscriptions and calls stopScan', () async {
      final m = buildMockService();
      container = createContainer(scannerService: m.service);
      final notifier = initNotifier(container!);

      await notifier.startScan();

      when(() => m.service.isScanningNow).thenReturn(true);

      container!.dispose();
      container = null;

      verify(() => m.service.stopScan()).called(1);
    });
  });
}
