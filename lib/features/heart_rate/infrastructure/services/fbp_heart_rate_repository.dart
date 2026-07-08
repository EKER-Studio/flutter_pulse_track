import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/models/hr_measurement.dart';
import '../../domain/services/heart_rate_repository.dart';
import '../parsers/hr_packet_parser.dart';

class FbpHeartRateRepository implements HeartRateRepository {
  final BluetoothDevice _device;

  // Heart Rate Service UUID: 0x180D, Measurement Characteristic UUID: 0x2A37
  static const String _hrCharacteristicUuid = '2a37';

  FbpHeartRateRepository(String deviceId) : _device = BluetoothDevice.fromId(deviceId);

  @override
  Stream<HrMeasurement> get heartRateStream {
    final controller = StreamController<HrMeasurement>();

    _device.services.listen((services) async {
      try {
        final hrService = services.firstWhere(
              (s) => s.serviceUuid.toString().contains('180d'),
        );

        final characteristic = hrService.characteristics.firstWhere(
              (c) => c.characteristicUuid.toString().contains(_hrCharacteristicUuid),
        );

        // Enable GATT notifications/indications for real-time streaming
        await characteristic.setNotifyValue(true);

        final subscription = characteristic.onValueReceived.listen((rawBytes) {
          final measurement = HrPacketParser.parseRawBytes(rawBytes);
          if (measurement != null) {
            controller.add(measurement);
          }
        });

        controller.onCancel = () {
          subscription.cancel();
          characteristic.setNotifyValue(false);
        };
      } catch (e) {
        controller.addError(e);
      }
    });

    return controller.stream;
  }
}
