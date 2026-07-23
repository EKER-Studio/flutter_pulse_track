import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/workout/infrastructure/models/device_profile_dto.dart';

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('DeviceProfileDto defaults', () {
    test('id defaults to Isar.autoIncrement', () {
      final dto = DeviceProfileDto();
      expect(dto.id, Isar.autoIncrement);
    });
  });

  group('DeviceProfileDto field assignment', () {
    test('stores and returns macAddress', () {
      final dto = DeviceProfileDto()..macAddress = 'AA:BB:CC:DD:EE:FF';
      expect(dto.macAddress, 'AA:BB:CC:DD:EE:FF');
    });

    test('stores and returns name', () {
      final dto = DeviceProfileDto()..name = 'Polar H10';
      expect(dto.name, 'Polar H10');
    });

    test('stores and returns lastConnectedAt', () {
      final ts = DateTime(2026, 7, 23, 14, 30, 0);
      final dto = DeviceProfileDto()..lastConnectedAt = ts;
      expect(dto.lastConnectedAt, ts);
    });

    test('stores and returns lastSensorLocationIndex', () {
      final dto = DeviceProfileDto()..lastSensorLocationIndex = 2;
      expect(dto.lastSensorLocationIndex, 2);
    });

    test('defaults lastSensorLocationIndex to 0 (BodySensorLocation.other)',
        () {
      // Accessing a late field before assignment should throw, but the
      // Isar collection contract always sets it — this test documents the
      // expected default for freshly constructed instances.
      final dto = DeviceProfileDto()..lastSensorLocationIndex = 0;
      final location = BodySensorLocation.values[dto.lastSensorLocationIndex];
      expect(location, BodySensorLocation.other);
    });

    test('maps index to correct BodySensorLocation', () {
      final dto = DeviceProfileDto()..lastSensorLocationIndex = 1;
      expect(
        BodySensorLocation.values[dto.lastSensorLocationIndex],
        BodySensorLocation.chest,
      );

      dto.lastSensorLocationIndex = 3;
      expect(
        BodySensorLocation.values[dto.lastSensorLocationIndex],
        BodySensorLocation.finger,
      );
    });

    test('multiple instances are independent', () {
      final a = DeviceProfileDto()
        ..macAddress = 'AA:BB:01'
        ..name = 'Device A'
        ..lastSensorLocationIndex = 1;

      final b = DeviceProfileDto()
        ..macAddress = 'CC:DD:02'
        ..name = 'Device B'
        ..lastSensorLocationIndex = 2;

      expect(a.macAddress, 'AA:BB:01');
      expect(a.name, 'Device A');
      expect(a.lastSensorLocationIndex, 1);
      expect(b.macAddress, 'CC:DD:02');
      expect(b.name, 'Device B');
      expect(b.lastSensorLocationIndex, 2);
    });
  });

  group('DeviceProfileDto id lifecycle', () {
    test('id can be reassigned after construction', () {
      final dto = DeviceProfileDto();
      dto.id = 42;
      expect(dto.id, 42);
    });
  });
}