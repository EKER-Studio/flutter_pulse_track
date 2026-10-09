/// Standard Bluetooth SIG GATT specifications and 16-bit UUIDs for Heart Rate and Battery profiles.
abstract final class GattSpec {
  /// Heart Rate Service standard 16-bit UUID (0x180D).
  static const String heartRateServiceUuid = '180d';

  /// Heart Rate Measurement characteristic standard 16-bit UUID (0x2A37).
  ///
  /// Emits live heart rate, R-R intervals, and optional sensor contact / energy status via NOTIFY.
  static const String heartRateMeasurementCharUuid = '2a37';

  /// Body Sensor Location characteristic standard 16-bit UUID (0x2A38).
  ///
  /// Exposes physical sensor placement on the body (Chest, Wrist, Finger, etc.) via READ.
  static const String bodySensorLocationCharUuid = '2a38';

  /// Heart Rate Control Point characteristic standard 16-bit UUID (0x2A39).
  ///
  /// Allows writing 0x01 to reset the accumulated energy expended counter via WRITE.
  static const String heartRateControlPointCharUuid = '2a39';

  /// Battery Service standard 16-bit UUID (0x180F).
  static const String batteryServiceUuid = '180f';

  /// Battery Level characteristic standard 16-bit UUID (0x2A19).
  ///
  /// Exposes current remaining battery percentage (0-100) via READ and NOTIFY.
  static const String batteryLevelCharUuid = '2a19';
}
