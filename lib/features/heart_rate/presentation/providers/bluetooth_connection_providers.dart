import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/ble_connection_state.dart';
import '../../domain/services/bluetooth_connection_service.dart';
import '../../infrastructure/services/fbp_bluetooth_connection_service.dart';

part 'bluetooth_connection_providers.g.dart';

/// Provides the concrete implementation of the connection service.
@riverpod
BluetoothConnectionService bluetoothConnectionService(Ref ref) {
  return FbpBluetoothConnectionService();
}

/// Exposes a reactive stream of the current BLE connection status to the UI.
@riverpod
Stream<BleConnectionStatus> bleConnectionStatus(Ref ref) {
  final connectionService = ref.watch(bluetoothConnectionServiceProvider);
  return connectionService.connectionStatus;
}

/// Controller responsible for executing connect and disconnect intents.
@riverpod
class BluetoothConnectionController extends _$BluetoothConnectionController {
  @override
  void build() {
    // Initial state setup if needed, returns void as execution intents are separate.
    return;
  }

  /// Initiates a secure, persistent connection with a specific device.
  Future<void> connect(String deviceId) async {
    final connectionService = ref.read(bluetoothConnectionServiceProvider);
    await connectionService.connect(deviceId);
  }

  /// Gracefully closes the active connection and unsubscribes from GATT lifecycle.
  Future<void> disconnect() async {
    final connectionService = ref.read(bluetoothConnectionServiceProvider);
    await connectionService.disconnect();
  }
}