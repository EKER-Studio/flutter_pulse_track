import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/ble_connection_status.dart';
import '../../domain/services/bluetooth_connection_service.dart';
import '../../infrastructure/services/fbp_bluetooth_connection_service.dart';

part 'bluetooth_connection_providers.g.dart';

/// Provides the concrete implementation of the connection service.
@riverpod
BluetoothConnectionService bluetoothConnectionService(Ref ref) {
  return FbpBluetoothConnectionService();
}

/// Controller responsible for managing connection state and executing lifecycle intents.
///
/// Replaces the legacy void controller with a robust AsyncValue wrapper driving the UI.
@riverpod
class BluetoothConnectionController extends _$BluetoothConnectionController {
  @override
  Stream<BleConnectionStatus> build() {
    final connectionService = ref.watch(bluetoothConnectionServiceProvider);
    return connectionService.connectionStatus;
  }

  /// Initiates a secure connection with a specific device, wrapping state transitions.
  Future<void> connect(String deviceId) async {
    final connectionService = ref.read(bluetoothConnectionServiceProvider);

    state = const AsyncValue.loading();

    try {
      await connectionService.connect(deviceId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Gracefully closes the active connection and unsubscribes from GATT lifecycle.
  Future<void> disconnect() async {
    final connectionService = ref.read(bluetoothConnectionServiceProvider);

    state = const AsyncValue.loading();

    try {
      await connectionService.disconnect();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
