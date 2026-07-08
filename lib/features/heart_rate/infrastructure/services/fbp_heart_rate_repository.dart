import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../domain/models/body_sensor_location.dart';
import '../../domain/models/hr_measurement.dart';
import '../../domain/services/heart_rate_repository.dart';
import '../parsers/hr_packet_parser.dart';

/// FlutterBluePlus implementation of the heart rate repository with embedded connection-resilience logic.
class FbpHeartRateRepository implements HeartRateRepository {
  final BluetoothDevice _device;

  static final Guid _hrServiceUuid = Guid('180d');
  static final Guid _hrCharacteristicUuid = Guid('2a37');

  FbpHeartRateRepository(String deviceId)
    : _device = BluetoothDevice.fromId(deviceId);

  @override
  Stream<HrMeasurement> get heartRateStream {
    final controller = StreamController<HrMeasurement>();
    StreamSubscription<List<int>>? notificationSubscription;

    Future<void> forceConnectAndDiscover() async {
      try {
        debugPrint(
          '--- [HARD REPO] Ensuring physical connection for ${_device.remoteId} ---',
        );

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
              .where(
                (c) => c.characteristicUuid == Guid('2a38'),
              ) // POPRAWIONE: brak przypisania, czysty Guid
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
          debugPrint(
            '--- [HARD REPO] Optional Sensor Location read failed or unsupported: $e ---',
          );
        }
        // --------------------------------------------------

        await characteristic.setNotifyValue(true);
        debugPrint('--- [HARD REPO] GATT Notifications Active! ---');

        notificationSubscription = characteristic.onValueReceived.listen((
          rawBytes,
        ) {
          final measurement = HrPacketParser.parseRawBytes(rawBytes);
          if (measurement != null && !controller.isClosed) {
            final updatedMeasurement = HrMeasurement(
              bpm: measurement.bpm,
              rrIntervals: measurement.rrIntervals,
              timestamp: measurement.timestamp,
              sensorLocation: discoveredLocation, // Przekazujemy enum
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
