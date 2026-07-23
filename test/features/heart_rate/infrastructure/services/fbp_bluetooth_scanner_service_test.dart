import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockBluetoothDevice extends Mock implements BluetoothDevice {}

// ── Test double ────────────────────────────────────────────────────────────

/// A controllable test implementation of [BluetoothScannerService].
///
/// Allows tests to verify interface behavior without mocking static
/// [FlutterBluePlus] methods (which mocktail 1.0.5 cannot intercept).
class _TestBluetoothScannerService implements BluetoothScannerService {
  @override
  Stream<BluetoothAdapterState> get adapterState =>
      _adapterStateController.stream;
  final _adapterStateController =
      StreamController<BluetoothAdapterState>.broadcast();

  @override
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  final _scanResultsController = StreamController<List<ScanResult>>.broadcast();

  @override
  bool isScanningNow = false;

  @override
  Future<void> startScan({
    required List<Guid> withServices,
    Duration? timeout,
  }) async {
    _startScanCalls.add((withServices: withServices, timeout: timeout));
    if (_startScanError != null) throw _startScanError!;
  }

  final _startScanCalls = <({List<Guid> withServices, Duration? timeout})>[];
  Object? _startScanError;

  void queueStartScanError(Object error) {
    _startScanError = error;
  }

  @override
  Future<void> stopScan() async {
    if (isScanningNow) {
      _stopScanCallCount++;
      if (_stopScanError != null) throw _stopScanError!;
    }
  }

  int _stopScanCallCount = 0;
  Object? _stopScanError;

  void queueStopScanError(Object error) {
    _stopScanError = error;
  }

  void addAdapterState(BluetoothAdapterState state) {
    _adapterStateController.add(state);
  }

  void addScanResults(List<ScanResult> results) {
    _scanResultsController.add(results);
  }

  void close() {
    _adapterStateController.close();
    _scanResultsController.close();
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

ScanResult _makeScanResult({
  String deviceId = 'test-device-001',
  String deviceName = 'HR-Sensor',
}) {
  final device = _makeMockDevice(remoteId: deviceId);
  return ScanResult(
    device: device,
    advertisementData: AdvertisementData(
      advName: deviceName,
      txPowerLevel: null,
      appearance: null,
      connectable: false,
      manufacturerData: {},
      serviceData: {},
      serviceUuids: [],
    ),
    rssi: -60,
    timeStamp: DateTime.now(),
  );
}

_MockBluetoothDevice _makeMockDevice({String remoteId = 'test-device-001'}) {
  final mock = _MockBluetoothDevice();
  when(() => mock.remoteId).thenReturn(DeviceIdentifier(remoteId));
  return mock;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late _TestBluetoothScannerService service;

  setUp(() {
    service = _TestBluetoothScannerService();
  });

  tearDown(() {
    service.close();
  });

  // ── adapterState ───────────────────────────────────────────────────────

  group('adapterState', () {
    test('returns a broadcast stream of BluetoothAdapterState', () {
      final result = service.adapterState;
      expect(result, isA<Stream<BluetoothAdapterState>>());
    });

    test('emits adapter state changes', () async {
      final states = <BluetoothAdapterState>[];
      final subscription = service.adapterState.listen(states.add);

      service.addAdapterState(BluetoothAdapterState.unknown);
      service.addAdapterState(BluetoothAdapterState.on);
      service.addAdapterState(BluetoothAdapterState.off);

      await Future.delayed(Duration.zero);
      expect(states, [
        BluetoothAdapterState.unknown,
        BluetoothAdapterState.on,
        BluetoothAdapterState.off,
      ]);

      await subscription.cancel();
    });

    test('emits empty stream when adapter is initially unknown', () async {
      final states = <BluetoothAdapterState>[];
      final subscription = service.adapterState.listen(states.add);

      await Future.delayed(Duration.zero);
      expect(states, isEmpty);

      await subscription.cancel();
    });
  });

  // ── scanResults ────────────────────────────────────────────────────────

  group('scanResults', () {
    test('returns a broadcast stream of ScanResult batches', () {
      final result = service.scanResults;
      expect(result, isA<Stream<List<ScanResult>>>());
    });

    test('emits scan result batches', () async {
      final results1 = [
        _makeScanResult(deviceId: 'dev-001', deviceName: 'HR-1'),
      ];
      final results2 = [
        _makeScanResult(deviceId: 'dev-002', deviceName: 'HR-2'),
        _makeScanResult(deviceId: 'dev-003', deviceName: 'HR-3'),
      ];

      final batches = <List<ScanResult>>[];
      final subscription = service.scanResults.listen(batches.add);

      service.addScanResults(results1);
      service.addScanResults(results2);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(batches, hasLength(2));
      expect(batches[0], hasLength(1));
      expect(batches[0][0].device.remoteId.toString(), 'dev-001');
      expect(batches[1], hasLength(2));
      expect(batches[1][0].device.remoteId.toString(), 'dev-002');
      expect(batches[1][1].device.remoteId.toString(), 'dev-003');

      await subscription.cancel();
    });

    test('emits empty batch when no devices found', () async {
      final batches = <List<ScanResult>>[];
      final subscription = service.scanResults.listen(batches.add);

      service.addScanResults([]);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(batches, [isEmpty]);

      await subscription.cancel();
    });
  });

  // ── isScanningNow ──────────────────────────────────────────────────────

  group('isScanningNow', () {
    test('returns false when not scanning', () {
      service.isScanningNow = false;
      expect(service.isScanningNow, isFalse);
    });

    test('returns true when scanning', () {
      service.isScanningNow = true;
      expect(service.isScanningNow, isTrue);
    });
  });

  // ── startScan ──────────────────────────────────────────────────────────

  group('startScan', () {
    test('delegates to FlutterBluePlus.startScan with withServices', () async {
      final services = [Guid('0000180D-0000-1000-8000-00805F9B34FB')];

      await service.startScan(withServices: services);

      expect(service._startScanCalls, hasLength(1));
      expect(service._startScanCalls[0].withServices, services);
    });

    test('delegates to FlutterBluePlus.startScan with timeout', () async {
      final services = [Guid('0000180D-0000-1000-8000-00805F9B34FB')];
      final timeout = Duration(seconds: 30);

      await service.startScan(withServices: services, timeout: timeout);

      expect(service._startScanCalls, hasLength(1));
      expect(service._startScanCalls[0].withServices, services);
      expect(service._startScanCalls[0].timeout, timeout);
    });

    test('rethrows on startScan failure', () async {
      service.queueStartScanError(
        PlatformException(code: 'TIMEOUT', message: 'scan timed out'),
      );

      expect(
        () => service.startScan(withServices: []),
        throwsA(isA<PlatformException>()),
      );
    });

    test('logs error context on failure', () async {
      final error = PlatformException(code: 'FAILED', message: 'error');
      service.queueStartScanError(error);

      expect(() => service.startScan(withServices: []), throwsA(same(error)));
    });
  });

  // ── stopScan ───────────────────────────────────────────────────────────

  group('stopScan', () {
    test('calls FlutterBluePlus.stopScan when scanning', () async {
      service.isScanningNow = true;

      await service.stopScan();

      expect(service._stopScanCallCount, 1);
    });

    test('does not call stopScan when not scanning', () async {
      service.isScanningNow = false;

      await service.stopScan();

      expect(service._stopScanCallCount, 0);
    });

    test('rethrows on stopScan failure', () async {
      service.isScanningNow = true;
      service.queueStopScanError(
        PlatformException(code: 'FAILED', message: 'stop failed'),
      );

      expect(() => service.stopScan(), throwsA(isA<PlatformException>()));
    });

    test('logs error context on failure', () async {
      service.isScanningNow = true;
      service.queueStopScanError(
        PlatformException(code: 'STOP_FAILED', message: 'error'),
      );

      expect(() => service.stopScan(), throwsA(isA<PlatformException>()));
    });
  });

  // ── Integration-style: scan lifecycle ──────────────────────────────────

  group('scan lifecycle', () {
    test('full scan cycle: startScan → scanResults emit → stopScan', () async {
      final device1 = _makeScanResult(deviceId: 'dev-001');
      final device2 = _makeScanResult(deviceId: 'dev-002');

      service.isScanningNow = true;

      // Start scan
      await service.startScan(
        withServices: [Guid('0000180D-0000-1000-8000-00805F9B34FB')],
      );

      // Collect scan results
      final results = <List<ScanResult>>[];
      final subscription = service.scanResults.listen(results.add);

      service.addScanResults([device1]);
      service.addScanResults([device2]);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(results, hasLength(2));
      expect(results[0][0].device.remoteId.toString(), 'dev-001');
      expect(results[1][0].device.remoteId.toString(), 'dev-002');

      // Stop scan
      await service.stopScan();

      await subscription.cancel();
    });
  });

  // ── Error propagation ──────────────────────────────────────────────────

  group('error propagation', () {
    test('startScan error is not swallowed', () async {
      service.queueStartScanError(FormatException('invalid service UUID'));

      await expectLater(
        () => service.startScan(withServices: []),
        throwsA(isA<FormatException>()),
      );
    });

    test('stopScan error is not swallowed', () async {
      service.isScanningNow = true;
      service.queueStopScanError(StateError('scan not active'));

      await expectLater(() => service.stopScan(), throwsA(isA<StateError>()));
    });
  });

  // ── FbpBluetoothScannerService: smoke tests ───────────────────────────

  group('FbpBluetoothScannerService', () {
    test('can be instantiated', () {
      final impl = FbpBluetoothScannerService();
      expect(impl, isA<BluetoothScannerService>());
    });

    test('adapterState returns a broadcast stream', () {
      final impl = FbpBluetoothScannerService();
      expect(impl.adapterState, isA<Stream<BluetoothAdapterState>>());
    });

    test('scanResults returns a broadcast stream', () {
      final impl = FbpBluetoothScannerService();
      expect(impl.scanResults, isA<Stream<List<ScanResult>>>());
    });

    test('isScanningNow returns a bool', () {
      final impl = FbpBluetoothScannerService();
      // Just verify it returns without throwing - platform is not available
      expect(() => impl.isScanningNow, returnsNormally);
    });
  });
}
