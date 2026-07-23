import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_connection_status.dart';

void main() {
  group('BleConnectionStatus', () {
    test('has exactly 4 values', () {
      expect(BleConnectionStatus.values, hasLength(4));
    });

    test('contains disconnected', () {
      expect(BleConnectionStatus.values, contains(BleConnectionStatus.disconnected));
    });

    test('contains connecting', () {
      expect(BleConnectionStatus.values, contains(BleConnectionStatus.connecting));
    });

    test('contains connected', () {
      expect(BleConnectionStatus.values, contains(BleConnectionStatus.connected));
    });

    test('contains disconnecting', () {
      expect(BleConnectionStatus.values, contains(BleConnectionStatus.disconnecting));
    });

    test('exhaustive switch over all variants', () {
      for (final status in BleConnectionStatus.values) {
        final label = switch (status) {
          BleConnectionStatus.disconnected => 'disconnected',
          BleConnectionStatus.connecting => 'connecting',
          BleConnectionStatus.connected => 'connected',
          BleConnectionStatus.disconnecting => 'disconnecting',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}