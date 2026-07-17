import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/services/heart_rate_repository.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/infrastructure/parsers/hr_packet_parser.dart';

/// FlutterBluePlus implementation of the heart rate repository with embedded connection-resilience logic.
///
/// Handles the full GATT lifecycle: connects to the peripheral, discovers services,
/// reads optional characteristics (body sensor location, battery level), and sets up
/// notifications on the Heart Rate Measurement characteristic. All optional reads are
/// defensive — failures do not interrupt the telemetry stream.
class FbpHeartRateRepository implements HeartRateRepository {
  final BluetoothDevice _device;

  /// UUID for the standard Heart Rate service (0x180D).
  static final Guid _hrServiceUuid = Guid('180d');

  /// UUID for the Heart Rate Measurement characteristic (0x2A37).
  static final Guid _hrCharacteristicUuid = Guid('2a37');

  /// UUID for the standard Battery Service (0x180F).
  static final Guid _batteryServiceUuid = Guid('180f');

  /// UUID for the Battery Level characteristic (0x2A19).
  static final Guid _batteryLevelUuid = Guid('2a19');

  /// Creates a repository bound to the device identified by [deviceId].
  FbpHeartRateRepository(String deviceId)
    : _device = BluetoothDevice.fromId(deviceId);

  @override
  /// Returns a stream of [HrMeasurement] objects parsed from raw GATT notifications.
  ///
  /// On first access, performs a hard connect and service discovery. Optionally reads
  /// the Body Sensor Location (0x2A38) and Battery Level (0x2A19) characteristics,
  /// injecting the discovered values into every emitted measurement. The returned
  /// stream controller is self-cleaning: cancelling the stream disposes the underlying
  /// GATT notification subscription.
  Stream<HrMeasurement> get heartRateStream {
    final controller = StreamController<HrMeasurement>();
    StreamSubscription<List<int>>? notificationSubscription;

    Future<void> forceConnectAndDiscover() async {
      try {
        debugPrint(
          '--- [HARD REPO] Ensuring physical connection for ${_device.remoteId} ---',
        );

        // Hard-connect directly inside the data stream to bypass provider race conditions
        await _device
            .connect(autoConnect: false)
            .timeout(
              const Duration(seconds: 4),
              onTimeout: () => debugPrint(
                '--- [HARD REPO] Device already connecting or handled by system ---',
              ),
            );

        debugPrint(
          '--- [HARD REPO] Triggering discoverServices() with safety timeout ---',
        );
        // Bound discoverServices to prevent infinite waiting states if GATT discovery freezes
        final services = await _device.discoverServices().timeout(
          const Duration(seconds: 5),
          onTimeout: () =>
              throw TimeoutException('GATT service discovery timed out'),
        );
        debugPrint(
          '--- [HARD REPO] Services discovered: ${services.length} ---',
        );

        final hrService = services
            .where((s) => s.serviceUuid == _hrServiceUuid)
            .firstOrNull;
        if (hrService == null) {
          controller.addError(
            StateError('Heart Rate Service (180D) not found.'),
          );
          return;
        }

        final characteristic = hrService.characteristics
            .where((c) => c.characteristicUuid == _hrCharacteristicUuid)
            .firstOrNull;

        if (characteristic == null) {
          controller.addError(
            StateError('HR Measurement Characteristic (2A37) not found.'),
          );
          return;
        }

        // --- Dynamic Body Sensor Location Read (0x2A38) ---
        BodySensorLocation discoveredLocation = BodySensorLocation.unknown;
        try {
          final locationChar = hrService.characteristics
              .where((c) => c.characteristicUuid == Guid('2a38'))
              .firstOrNull;

          if (locationChar != null) {
            debugPrint('--- [HARD REPO] Reading Body Sensor Location... ---');
            final List<int> locationBytes = await locationChar.read().timeout(
              const Duration(seconds: 2),
            );

            if (locationBytes.isNotEmpty) {
              final int locationCode = locationBytes.first;
              discoveredLocation = switch (locationCode) {
                1 => BodySensorLocation.chest,
                2 => BodySensorLocation.wrist,
                3 => BodySensorLocation.finger,
                4 => BodySensorLocation.hand,
                5 => BodySensorLocation.earLobe,
                6 => BodySensorLocation.foot,
                _ => BodySensorLocation.other,
              };
              debugPrint(
                '--- [HARD REPO] Sensor Location resolved: ${discoveredLocation.name} ---',
              );
            }
          }
        } catch (e) {
          // Defensive fallback: do not interrupt telemetry stream if 0x2A38 reading fails
          debugPrint(
            '--- [HARD REPO] Optional Sensor Location read failed or unsupported: $e ---',
          );
        }

        // --- Dynamic Battery Level Read (0x180F -> 0x2A19) ---
        int? discoveredBatteryLevel;
        try {
          final batteryService = services
              .where((s) => s.serviceUuid == _batteryServiceUuid)
              .firstOrNull;

          if (batteryService != null) {
            final batteryChar = batteryService.characteristics
                .where((c) => c.characteristicUuid == _batteryLevelUuid)
                .firstOrNull;

            if (batteryChar != null) {
              debugPrint('--- [HARD REPO] Reading Battery Level... ---');
              final List<int> batteryBytes = await batteryChar.read().timeout(
                const Duration(seconds: 2),
              );

              if (batteryBytes.isNotEmpty) {
                final rawBattery = batteryBytes.first;
                // Clamp value between 0 and 100 just to clean up rogue hardware frames
                discoveredBatteryLevel = rawBattery.clamp(0, 100);
                debugPrint(
                  '--- [HARD REPO] Battery Level resolved: $discoveredBatteryLevel% ---',
                );
              }
            }
          }
        } catch (e) {
          // Defensive fallback: do not interrupt telemetry stream if battery reading fails
          debugPrint(
            '--- [HARD REPO] Optional Battery Service read failed or unsupported: $e ---',
          );
        }

        await characteristic.setNotifyValue(true);
        debugPrint('--- [HARD REPO] GATT Notifications Active! ---');

        notificationSubscription = characteristic.onValueReceived.listen((
          rawBytes,
        ) {
          final measurement = HrPacketParser.parseRawBytes(rawBytes);
          if (measurement != null && !controller.isClosed) {
            // Enforce the dynamically discovered hardware states on every incoming domain entity
            final updatedMeasurement = HrMeasurement(
              bpm: measurement.bpm,
              rrIntervals: measurement.rrIntervals,
              timestamp: measurement.timestamp,
              sensorLocation: discoveredLocation,
              batteryLevel: discoveredBatteryLevel,
            );
            controller.add(updatedMeasurement);
          }
        }, onError: (err) => controller.addError(err));
      } catch (e) {
        debugPrint('--- [HARD REPO] CRITICAL ERROR: $e ---');
        if (!controller.isClosed) controller.addError(e);
      }
    }

    forceConnectAndDiscover();

    controller.onCancel = () async {
      debugPrint(
        '--- [HARD REPO] Tearing down heart rate stream subscriptions ---',
      );
      await notificationSubscription?.cancel();
      if (!controller.isClosed) {
        await controller.close();
      }
    };

    return controller.stream;
  }
}
