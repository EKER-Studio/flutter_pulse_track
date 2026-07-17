/// Lightweight domain model representing a discovered BLE peripheral.
///
/// Equality is based solely on [id], so two instances with the same
/// MAC address are considered identical regardless of RSSI or name.
class BleDevice {
  /// Unique hardware identifier (MAC address string).
  final String id;

  /// Human-readable device name advertised during scanning.
  final String name;

  /// Received Signal Strength Indicator in dBm.
  final int rssi;

  /// Creates a [BleDevice] from scan results.
  const BleDevice({required this.id, required this.name, required this.rssi});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
