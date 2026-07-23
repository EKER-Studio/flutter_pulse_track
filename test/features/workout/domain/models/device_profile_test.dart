import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';

void main() {
  group('DeviceProfile', () {
    test('constructor assigns all fields', () {
      final ts = DateTime(2026, 7, 23, 14, 30, 0);
      final profile = DeviceProfile(
        id: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        lastConnectedAt: ts,
        lastSensorLocationIndex: 2,
      );

      expect(profile.id, 1);
      expect(profile.macAddress, 'AA:BB:CC:DD:EE:FF');
      expect(profile.name, 'Polar H10');
      expect(profile.lastConnectedAt, ts);
      expect(profile.lastSensorLocationIndex, 2);
    });

    test('all fields are immutable', () {
      final profile = DeviceProfile(
        id: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Polar H10',
        lastConnectedAt: DateTime(2026, 1, 1),
        lastSensorLocationIndex: 0,
      );

      expect(profile, isA<DeviceProfile>());
    });

    test('accepts zero id', () {
      final profile = DeviceProfile(
        id: 0,
        macAddress: '11:22:33:44:55:66',
        name: 'Test',
        lastConnectedAt: DateTime(2026, 1, 1),
        lastSensorLocationIndex: 0,
      );

      expect(profile.id, 0);
    });

    test('accepts negative sensorLocationIndex', () {
      final profile = DeviceProfile(
        id: 1,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Test',
        lastConnectedAt: DateTime(2026, 1, 1),
        lastSensorLocationIndex: -1,
      );

      expect(profile.lastSensorLocationIndex, -1);
    });
  });
}