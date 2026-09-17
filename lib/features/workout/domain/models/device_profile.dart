/// Immutable domain representation of a previously-connected BLE heart rate
/// sensor, decoupled from the Isar persistence schema ([DeviceProfileDto]).
///
/// Presentation-layer code should depend on this type — never on
/// `DeviceProfileDto` directly — so the UI has zero knowledge of how (or
/// whether) profiles are actually stored.
class DeviceProfile {
  /// Stable identifier assigned by the persistence layer.
  final int id;

  /// Bluetooth hardware address (MAC on Android, stable UUID on iOS)
  /// uniquely identifying the physical sensor.
  final String macAddress;

  /// Human-readable display name last broadcast by the sensor.
  final String name;

  /// UTC timestamp of the most recent successful GATT connection.
  final DateTime lastConnectedAt;

  /// Raw index of the `BodySensorLocation` enum read from GATT
  /// characteristic 0x2A38 during the last session with this sensor.
  final int lastSensorLocationIndex;

  const DeviceProfile({
    required this.id,
    required this.macAddress,
    required this.name,
    required this.lastConnectedAt,
    required this.lastSensorLocationIndex,
  });
}
