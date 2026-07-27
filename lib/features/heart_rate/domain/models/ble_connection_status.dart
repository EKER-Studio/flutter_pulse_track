/// Represents the current lifecycle state of a Bluetooth Low Energy connection.
///
/// Used across domain and presentation layers to reflect device link status.
enum BleConnectionStatus {
  /// The BLE peripheral is disconnected.
  disconnected,

  /// A link-layer connection is currently being established.
  connecting,

  /// The BLE link is connected and GATT communication channels are available.
  connected,

  /// The connection to the BLE peripheral is being gracefully torn down.
  disconnecting,
}
