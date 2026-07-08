import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/models/hr_measurement.dart';
import '../../domain/services/heart_rate_repository.dart';
import '../parsers/hr_packet_parser.dart';

class FbpHeartRateRepository implements HeartRateRepository {
  final BluetoothDevice _device;

  static final Guid _hrServiceUuid = Guid('180d');
  static final Guid _hrCharacteristicUuid = Guid('2a37');

  FbpHeartRateRepository(String deviceId) : _device = BluetoothDevice.fromId(deviceId);

  @override
  Stream<HrMeasurement> get heartRateStream {
    final controller = StreamController<HrMeasurement>();
    StreamSubscription<List<int>>? notificationSubscription;

    Future<void> forceConnectAndDiscover() async {
      try {
        print('--- [HARD REPO] Ensuring physical connection for ${_device.remoteId} ---');

        // Hard-connect directly inside the data stream to bypass provider race conditions
        await _device.connect(autoConnect: false).timeout(
          const Duration(seconds: 4),
          onTimeout: () => print('--- [HARD REPO] Device already connecting or handled by system ---'),
        );

        print('--- [HARD REPO] Triggering discoverServices() ---');
        final services = await _device.discoverServices();
        print('--- [HARD REPO] Services discovered: ${services.length} ---');

        final hrService = services.where((s) => s.serviceUuid == _hrServiceUuid).firstOrNull;
        if (hrService == null) {
          controller.addError(StateError('Heart Rate Service (180D) not found.'));
          return;
        }

        final characteristic = hrService.characteristics
            .where((c) => c.characteristicUuid == _hrCharacteristicUuid)
            .firstOrNull;

        if (characteristic == null) {
          controller.addError(StateError('HR Measurement Characteristic (2A37) not found.'));
          return;
        }

        await characteristic.setNotifyValue(true);
        print('--- [HARD REPO] GATT Notifications Active! ---');

        notificationSubscription = characteristic.onValueReceived.listen(
              (rawBytes) {
            final measurement = HrPacketParser.parseRawBytes(rawBytes);
            if (measurement != null && !controller.isClosed) {
              controller.add(measurement);
            }
          },
          onError: (err) => controller.addError(err),
        );
      } catch (e) {
        print('--- [HARD REPO] CRITICAL ERROR: $e ---');
        if (!controller.isClosed) controller.addError(e);
      }
    }

    forceConnectAndDiscover();

    controller.onCancel = () async {
      await notificationSubscription?.cancel();
    };

    return controller.stream;
  }
}
