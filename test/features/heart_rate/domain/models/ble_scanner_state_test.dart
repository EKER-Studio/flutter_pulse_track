import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';

void main() {
  group('BleScannerState', () {
    test('idle can be constructed', () {
      final state = BleScannerState.idle();
      expect(state, isA<BleScannerState>());
    });

    test('idle is IdleScannerState', () {
      expect(BleScannerState.idle(), isA<IdleScannerState>());
    });

    test('scanning can be constructed with devices', () {
      final device = BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Polar H10', rssi: -55);
      final state = BleScannerState.scanning(devices: [device]);

      expect(state, isA<BleScannerState>());
    });

    test('scanning provides devices', () {
      final device = BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Polar H10', rssi: -55);
      final state = BleScannerState.scanning(devices: [device]) as ScanningScannerState;

      expect(state.devices, [device]);
    });

    test('scanning with multiple devices', () {
      final d1 = BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Polar H10', rssi: -55);
      final d2 = BleDevice(id: '11:22:33:44:55:66', name: 'Garmin', rssi: -60);
      final state = BleScannerState.scanning(devices: [d1, d2]) as ScanningScannerState;

      expect(state.devices, hasLength(2));
      expect(state.devices[0], d1);
      expect(state.devices[1], d2);
    });

    test('scanning with empty devices list', () {
      final state = BleScannerState.scanning(devices: []) as ScanningScannerState;

      expect(state.devices, isEmpty);
    });

    test('empty can be constructed', () {
      final state = BleScannerState.empty();
      expect(state, isA<BleScannerState>());
    });

    test('empty is EmptyScannerState', () {
      expect(BleScannerState.empty(), isA<EmptyScannerState>());
    });

    test('adapterOff can be constructed', () {
      final state = BleScannerState.adapterOff();
      expect(state, isA<BleScannerState>());
    });

    test('adapterOff is AdapterOffScannerState', () {
      expect(BleScannerState.adapterOff(), isA<AdapterOffScannerState>());
    });

    test('failure can be constructed with message', () {
      final state = BleScannerState.failure(message: 'Scan error');
      expect(state, isA<BleScannerState>());
    });

    test('failure provides message', () {
      final state = BleScannerState.failure(message: 'Bluetooth crashed')
          as FailureScannerState;

      expect(state.message, 'Bluetooth crashed');
    });

    test('failure with empty message', () {
      final state = BleScannerState.failure(message: '') as FailureScannerState;

      expect(state.message, '');
    });

    test('exhaustive switch over all variants', () {
      final states = <BleScannerState>[
        BleScannerState.idle(),
        BleScannerState.scanning(devices: []),
        BleScannerState.empty(),
        BleScannerState.adapterOff(),
        BleScannerState.failure(message: 'err'),
      ];

      for (final s in states) {
        final label = switch (s) {
          IdleScannerState _ => 'idle',
          ScanningScannerState _ => 'scanning',
          EmptyScannerState _ => 'empty',
          AdapterOffScannerState _ => 'adapterOff',
          FailureScannerState _ => 'failure',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}