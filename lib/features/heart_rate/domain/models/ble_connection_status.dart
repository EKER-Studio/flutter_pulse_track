/// Represents the current lifecycle state of a Bluetooth Low Energy connection.
enum BleConnectionStatus {
  /// The BLE peripheral is not connected.
  disconnected,

  /// A BLE link-layer connection is being established.
  connecting,

  /// The BLE link is connected and GATT channels are available.
  connected,

  /// The connection is being gracefully torn down.
  disconnecting,
}
