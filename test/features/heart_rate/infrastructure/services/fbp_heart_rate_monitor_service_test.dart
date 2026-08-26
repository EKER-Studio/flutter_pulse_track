import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockBluetoothDevice extends Mock implements BluetoothDevice {}

class _MockBluetoothCharacteristic extends Mock
    implements BluetoothCharacteristic {}

class _MockBluetoothService extends Mock implements BluetoothService {}

// ── Helpers ────────────────────────────────────────────────────────────────

BluetoothDevice _makeDevice({String id = 'test-device-001'}) {
  final mock = _MockBluetoothDevice();
  when(() => mock.remoteId).thenReturn(DeviceIdentifier(id));
  return mock;
}

BluetoothCharacteristic _makeCharacteristic({
  String serviceUuid = '0000180D-0000-1000-8000-00805F9B34FB',
  String characteristicUuid = '00002A37-0000-1000-8000-00805F9B34FB',
}) {
  final mock = _MockBluetoothCharacteristic();
  when(() => mock.remoteId).thenReturn(DeviceIdentifier('test-device-001'));
  when(() => mock.serviceUuid).thenReturn(Guid(serviceUuid));
  when(() => mock.characteristicUuid).thenReturn(Guid(characteristicUuid));
  when(() => mock.uuid).thenReturn(Guid(characteristicUuid));
  when(() => mock.instanceId).thenReturn(0);
  return mock;
}

BluetoothService _makeService({
  String serviceUuid = '0000180D-0000-1000-8000-00805F9B34FB',
  List<BluetoothCharacteristic> characteristics = const [],
}) {
  final mock = _MockBluetoothService();
  when(() => mock.serviceUuid).thenReturn(Guid(serviceUuid));
  when(() => mock.uuid).thenReturn(Guid(serviceUuid));
  when(() => mock.isPrimary).thenReturn(true);
  when(() => mock.isSecondary).thenReturn(false);
  when(() => mock.characteristics).thenReturn(characteristics);
  when(() => mock.includedServices).thenReturn([]);
  when(() => mock.primaryService).thenReturn(null);
  return mock;
}

StreamController<BluetoothConnectionState> _makeConnectionStateStream({
  required BluetoothDevice device,
}) {
  final controller = StreamController<BluetoothConnectionState>.broadcast();
  when(() => device.connectionState).thenAnswer((_) => controller.stream);
  return controller;
}

StreamController<List<int>> _makeOnValueReceivedStream({
  required BluetoothCharacteristic characteristic,
}) {
  final controller = StreamController<List<int>>.broadcast();
  when(
    () => characteristic.onValueReceived,
  ).thenAnswer((_) => controller.stream);
  return controller;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late HeartRateMonitorService service;
  late BluetoothDevice device;
  late BluetoothCharacteristic characteristic;
  late BluetoothService hrService;

  setUp(() {
    service = const FbpHeartRateMonitorService();
    device = _makeDevice();
    characteristic = _makeCharacteristic();
    hrService = _makeService();
  });

  tearDown(() async {
    // No-op: BluetoothDevice.fromId triggers platform init which is unsupported in tests.
    // Stream subscriptions are cleaned up by Flutter's test harness.
  });

  // ── fromId ─────────────────────────────────────────────────────────────

  group('fromId', () {
    test('returns a BluetoothDevice with the given id', () {
      final result = service.fromId('test-device-001');
      expect(result.remoteId.toString(), 'test-device-001');
    });

    test('returns different instances for different ids', () {
      final a = service.fromId('device-a');
      final b = service.fromId('device-b');
      expect(a.remoteId.toString(), 'device-a');
      expect(b.remoteId.toString(), 'device-b');
    });
  });

  // ── connect ────────────────────────────────────────────────────────────

  group('connect', () {
    test('delegates to device.connect with default autoConnect', () async {
      when(
        () => device.connect(
          license: any(named: 'license'),
          autoConnect: any(named: 'autoConnect'),
        ),
      ).thenAnswer((_) async {});

      await service.connect(device);

      verify(
        () => device.connect(license: License.nonprofit, autoConnect: false),
      ).called(1);
    });

    test('delegates to device.connect with autoConnect = true', () async {
      when(
        () => device.connect(
          license: any(named: 'license'),
          autoConnect: any(named: 'autoConnect'),
        ),
      ).thenAnswer((_) async {});

      await service.connect(device, autoConnect: true);

      verify(
        () => device.connect(license: License.nonprofit, autoConnect: true),
      ).called(1);
    });

    test('rethrows on connection failure', () async {
      final error = Exception('BLE connect failed');
      when(
        () => device.connect(
          license: any(named: 'license'),
          autoConnect: any(named: 'autoConnect'),
        ),
      ).thenThrow(error);

      expect(() => service.connect(device), throwsA(same(error)));
    });
  });

  // ── disconnect ─────────────────────────────────────────────────────────

  group('disconnect', () {
    test('delegates to device.disconnect', () async {
      when(() => device.disconnect()).thenAnswer((_) async {});

      await service.disconnect(device);

      verify(() => device.disconnect()).called(1);
    });

    test('rethrows on disconnect failure', () async {
      final error = Exception('BLE disconnect failed');
      when(() => device.disconnect()).thenThrow(error);

      expect(() => service.disconnect(device), throwsA(same(error)));
    });
  });

  // ── connectionState ────────────────────────────────────────────────────

  group('connectionState', () {
    test('returns device.connectionState stream', () async {
      final stateController = _makeConnectionStateStream(device: device);

      final result = service.connectionState(device);

      expect(result, isA<Stream<BluetoothConnectionState>>());

      // Verify the stream emits values
      final values = <BluetoothConnectionState>[];
      final subscription = result.listen(values.add);
      await Future.delayed(Duration.zero);

      stateController.add(BluetoothConnectionState.connected);
      stateController.add(BluetoothConnectionState.disconnected);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(values, [
        BluetoothConnectionState.connected,
        BluetoothConnectionState.disconnected,
      ]);

      await subscription.cancel();
      await stateController.close();
    });
  });

  // ── discoverServices ───────────────────────────────────────────────────

  group('discoverServices', () {
    test('returns list of BluetoothService from device', () async {
      when(
        () => device.discoverServices(),
      ).thenAnswer((_) async => [hrService]);

      final result = await service.discoverServices(device);

      expect(result, hasLength(1));
      expect(result.first.serviceUuid.toString(), '180d');
      verify(() => device.discoverServices()).called(1);
    });

    test('returns empty list when device has no services', () async {
      when(() => device.discoverServices()).thenAnswer((_) async => []);

      final result = await service.discoverServices(device);

      expect(result, isEmpty);
    });

    test('rethrows on discoverServices failure', () async {
      final error = Exception('BLE discoverServices failed');
      when(() => device.discoverServices()).thenThrow(error);

      expect(() => service.discoverServices(device), throwsA(same(error)));
    });
  });

  // ── setNotifyValue ─────────────────────────────────────────────────────

  group('setNotifyValue', () {
    test('delegates to characteristic.setNotifyValue(true)', () async {
      when(
        () => characteristic.setNotifyValue(any()),
      ).thenAnswer((_) async => true);

      await service.setNotifyValue(characteristic, true);

      verify(() => characteristic.setNotifyValue(true)).called(1);
    });

    test('delegates to characteristic.setNotifyValue(false)', () async {
      when(
        () => characteristic.setNotifyValue(any()),
      ).thenAnswer((_) async => true);

      await service.setNotifyValue(characteristic, false);

      verify(() => characteristic.setNotifyValue(false)).called(1);
    });

    test('rethrows on setNotifyValue failure', () async {
      final error = Exception('BLE setNotifyValue failed');
      when(() => characteristic.setNotifyValue(any())).thenThrow(error);

      expect(
        () => service.setNotifyValue(characteristic, true),
        throwsA(same(error)),
      );
    });
  });

  // ── onValueReceived ────────────────────────────────────────────────────

  group('onValueReceived', () {
    test('returns characteristic.onValueReceived stream', () async {
      final valueController = _makeOnValueReceivedStream(
        characteristic: characteristic,
      );

      final result = service.onValueReceived(characteristic);

      expect(result, isA<Stream<List<int>>>());

      // Verify the stream emits values
      final values = <List<int>>[];
      final subscription = result.listen(values.add);
      await Future.delayed(Duration.zero);

      final testData = [0x00, 120];
      valueController.add(testData);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(values, [testData]);

      await subscription.cancel();
      await valueController.close();
    });
  });

  // ── read ───────────────────────────────────────────────────────────────

  group('read', () {
    test('returns characteristic value', () async {
      final readValue = [0x00, 0x60, 0x00]; // BPM = 96, 16-bit
      when(() => characteristic.read()).thenAnswer((_) async => readValue);

      final result = await service.read(characteristic);

      expect(result, readValue);
      verify(() => characteristic.read()).called(1);
    });

    test('returns empty list when characteristic has no value', () async {
      when(() => characteristic.read()).thenAnswer((_) async => []);

      final result = await service.read(characteristic);

      expect(result, isEmpty);
    });

    test('rethrows on read failure', () async {
      final error = Exception('BLE read failed');
      when(() => characteristic.read()).thenThrow(error);

      expect(() => service.read(characteristic), throwsA(same(error)));
    });
  });

  // ── Integration-style: full service discovery flow ─────────────────────

  group('service discovery flow', () {
    test('discovers services and returns them in correct order', () async {
      // Simulate discovering HR service (0x180D) and Battery service (0x180F)
      final hrChar = _makeCharacteristic();
      final batteryChar = _makeCharacteristic(
        serviceUuid: '0000180F-0000-1000-8000-00805F9B34FB',
        characteristicUuid: '00002A19-0000-1000-8000-00805F9B34FB',
      );

      final hrService = _makeService(
        serviceUuid: '0000180D-0000-1000-8000-00805F9B34FB',
        characteristics: [hrChar],
      );
      final batteryService = _makeService(
        serviceUuid: '0000180F-0000-1000-8000-00805F9B34FB',
        characteristics: [batteryChar],
      );

      when(
        () => device.discoverServices(),
      ).thenAnswer((_) async => [hrService, batteryService]);

      final result = await service.discoverServices(device);

      expect(result, hasLength(2));
      expect(result[0].serviceUuid.toString(), '180d');
      expect(result[1].serviceUuid.toString(), '180f');
    });
  });

  // ── Error propagation ──────────────────────────────────────────────────

  group('error propagation', () {
    test('connect error is not swallowed', () async {
      when(
        () => device.connect(
          license: any(named: 'license'),
          autoConnect: any(named: 'autoConnect'),
        ),
      ).thenThrow(FormatException('device not found'));

      await expectLater(
        () => service.connect(device),
        throwsA(isA<FormatException>()),
      );
    });

    test('disconnect error is not swallowed', () async {
      when(
        () => device.disconnect(),
      ).thenThrow(StateError('already disconnected'));

      await expectLater(
        () => service.disconnect(device),
        throwsA(isA<StateError>()),
      );
    });

    test('discoverServices error is not swallowed', () async {
      when(() => device.discoverServices()).thenThrow(
        PlatformException(code: 'FAILED', message: 'discover failed'),
      );

      await expectLater(
        () => service.discoverServices(device),
        throwsA(isA<PlatformException>()),
      );
    });

    test('setNotifyValue error is not swallowed', () async {
      when(
        () => characteristic.setNotifyValue(any()),
      ).thenThrow(PlatformException(code: 'FAILED'));

      await expectLater(
        () => service.setNotifyValue(characteristic, true),
        throwsA(isA<PlatformException>()),
      );
    });

    test('read error is not swallowed', () async {
      when(
        () => characteristic.read(),
      ).thenThrow(PlatformException(code: 'READ_FAILED'));

      await expectLater(
        () => service.read(characteristic),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
