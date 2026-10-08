import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';

final Guid _kBodySensorLocationCharUuid = Guid('2a38');
final Guid _kBatteryServiceUuid = Guid('180f');
final Guid _kBatteryLevelCharacteristicUuid = Guid('2a19');

/// Discovers and reads optional standard GATT characteristics (Sensor Location, Battery).
class GattProfileResolver {
  final HeartRateMonitorService _monitorService;

  const GattProfileResolver(this._monitorService);

  /// Reads [BodySensorLocation] from the Heart Rate Service characteristic 0x2A38.
  Future<BodySensorLocation> readBodySensorLocation(
    BluetoothService hrService,
  ) async {
    try {
      final BluetoothCharacteristic? locationChar = hrService.characteristics
          .where(
            (BluetoothCharacteristic c) =>
                c.characteristicUuid == _kBodySensorLocationCharUuid,
          )
          .firstOrNull;

      if (locationChar == null) return BodySensorLocation.unknown;

      final List<int> bytes = await _monitorService
          .read(locationChar)
          .timeout(const Duration(seconds: 2));

      if (bytes.isEmpty) return BodySensorLocation.unknown;

      return switch (bytes.first) {
        1 => BodySensorLocation.chest,
        2 => BodySensorLocation.wrist,
        3 => BodySensorLocation.finger,
        4 => BodySensorLocation.hand,
        5 => BodySensorLocation.earLobe,
        6 => BodySensorLocation.foot,
        _ => BodySensorLocation.other,
      };
    } on Object catch (e) {
      log.w(
        '[GattProfileResolver] Optional 0x2A38 read failed (ignored)',
        error: e,
      );
      return BodySensorLocation.unknown;
    }
  }

  /// Discovers battery service, reads initial battery level, and sets up notifications if supported.
  Future<({int? initialLevel, StreamSubscription<List<int>>? subscription})>
  resolveBatteryService(
    List<BluetoothService> services, {
    required void Function(int level) onLevelChanged,
  }) async {
    try {
      final BluetoothService? batteryService = services
          .where((BluetoothService s) => s.serviceUuid == _kBatteryServiceUuid)
          .firstOrNull;

      if (batteryService == null) {
        log.d(
          '[GattProfileResolver] Battery Service (0x180F) not found on device.',
        );
        return (initialLevel: null, subscription: null);
      }

      final BluetoothCharacteristic? batteryChar = batteryService
          .characteristics
          .where(
            (BluetoothCharacteristic c) =>
                c.characteristicUuid == _kBatteryLevelCharacteristicUuid,
          )
          .firstOrNull;

      if (batteryChar == null) {
        log.d(
          '[GattProfileResolver] Battery Level Characteristic (0x2A19) not found.',
        );
        return (initialLevel: null, subscription: null);
      }

      int? initialLevel;
      try {
        final List<int> initialBytes = await _monitorService
            .read(batteryChar)
            .timeout(const Duration(seconds: 2));
        if (initialBytes.isNotEmpty) {
          initialLevel = initialBytes.first.clamp(0, 100);
          log.d(
            '[GattProfileResolver] Initial battery level read: $initialLevel%',
          );
        }
      } on TimeoutException {
        log.w(
          '[GattProfileResolver] Battery level initial read timed out (2 s) — '
          'will rely on notifications if available.',
        );
      } on Object catch (e) {
        log.e(
          '[GattProfileResolver] Battery level initial read failed',
          error: e,
        );
      }

      final bool supportsNotify = batteryChar.properties.notify;
      final bool supportsIndicate = batteryChar.properties.indicate;

      if (supportsNotify || supportsIndicate) {
        await _monitorService.setNotifyValue(batteryChar, true);

        return (
          initialLevel: initialLevel,
          subscription: _monitorService
              .onValueReceived(batteryChar)
              .listen(
                (List<int> bytes) {
                  if (bytes.isNotEmpty) {
                    onLevelChanged(bytes.first.clamp(0, 100));
                  }
                },
                onError: (Object error, StackTrace stack) {
                  log.e(
                    '[GattProfileResolver] Battery notification stream error',
                    error: error,
                  );
                },
                cancelOnError: false,
              ),
        );
      } else {
        log.d(
          '[GattProfileResolver] Battery characteristic found but does not '
          'support notifications/indications. Using initial read value.',
        );
      }

      return (initialLevel: initialLevel, subscription: null);
    } on Object catch (e) {
      log.w(
        '[GattProfileResolver] Battery service resolution failed (ignored)',
        error: e,
      );
      return (initialLevel: null, subscription: null);
    }
  }
}
