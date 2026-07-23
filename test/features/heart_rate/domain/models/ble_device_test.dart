import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';

void main() {
  group('BleDevice', () {
    test('constructor assigns all fields', () {
      final device = BleDevice(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        rssi: -55,
      );

      expect(device.id, 'AA:BB:CC:DD:EE:FF');
      expect(device.name, 'Polar H10');
      expect(device.rssi, -55);
    });

    test('constructor accepts zero rssi', () {
      final device = BleDevice(id: '11:22:33:44:55:66', name: 'Test', rssi: 0);

      expect(device.rssi, 0);
    });

    test('constructor accepts negative rssi', () {
      final device = BleDevice(
        id: '11:22:33:44:55:66',
        name: 'Test',
        rssi: -100,
      );

      expect(device.rssi, -100);
    });

    group('==', () {
      test('same id -> equal despite different name and rssi', () {
        final a = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );
        final b = BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Garmin', rssi: -60);

        expect(a, equals(b));
      });

      test('different id -> not equal', () {
        final a = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );
        final b = BleDevice(
          id: '11:22:33:44:55:66',
          name: 'Polar H10',
          rssi: -55,
        );

        expect(a, isNot(equals(b)));
      });

      test('different type -> not equal', () {
        final device = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );

        expect(device, isNot(equals(Object())));
      });

      test('identical instance -> equal', () {
        final device = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );

        expect(device == device, true);
      });
    });

    group('hashCode', () {
      test('same id -> same hashCode', () {
        final a = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );
        final b = BleDevice(id: 'AA:BB:CC:DD:EE:FF', name: 'Other', rssi: -99);

        expect(a.hashCode, equals(b.hashCode));
      });

      test('different id -> different hashCode', () {
        final a = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Polar H10',
          rssi: -55,
        );
        final b = BleDevice(
          id: '11:22:33:44:55:66',
          name: 'Polar H10',
          rssi: -55,
        );

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });
}
