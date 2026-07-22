import 'body_sensor_location.dart';

/// Single heart rate data point captured from a BLE sensor.
///
/// Aggregates instantaneous BPM, R-R intervals, sensor metadata, and
/// battery level into one immutable snapshot.
class HrMeasurement {
  /// Instantaneous heart rate in beats per minute.
  final int bpm;

  /// R-R intervals stored in seconds to closely align with standard sport metrics and HRV analysis.
  final List<double> rrIntervals;

  /// UTC moment at which this measurement was captured.
  final DateTime timestamp;

  /// Dynamic hardware placement location decoded via BLE GATT characteristic 0x2A38.
  final BodySensorLocation sensorLocation;

  /// Remaining device battery percentage (0-100), null if unsupported by hardware.
  final int? batteryLevel;

  /// Whether the sensor supports skin contact detection per Bluetooth SIG spec.
  final bool sensorContactSupported;

  /// Whether skin contact is detected, null if [sensorContactSupported] is false.
  final bool? sensorContactActive;

  const HrMeasurement({
    required this.bpm,
    required this.rrIntervals,
    required this.timestamp,
    this.sensorLocation = BodySensorLocation.unknown,
    this.batteryLevel,
    this.sensorContactSupported = false,
    this.sensorContactActive,
  });

  /// Creates a copy of this measurement but with the given fields replaced with the new values.
  HrMeasurement copyWith({
    int? bpm,
    List<double>? rrIntervals,
    DateTime? timestamp,
    BodySensorLocation? sensorLocation,
    int? batteryLevel,
    bool? sensorContactSupported,
    bool? sensorContactActive,
  }) {
    return HrMeasurement(
      bpm: bpm ?? this.bpm,
      rrIntervals: rrIntervals ?? this.rrIntervals,
      timestamp: timestamp ?? this.timestamp,
      sensorLocation: sensorLocation ?? this.sensorLocation,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      sensorContactSupported:
          sensorContactSupported ?? this.sensorContactSupported,
      sensorContactActive: sensorContactActive ?? this.sensorContactActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HrMeasurement &&
          runtimeType == other.runtimeType &&
          bpm == other.bpm &&
          timestamp == other.timestamp &&
          sensorLocation == other.sensorLocation &&
          batteryLevel == other.batteryLevel &&
          sensorContactSupported == other.sensorContactSupported &&
          sensorContactActive == other.sensorContactActive &&
          _listEquals(rrIntervals, other.rrIntervals);

  @override
  int get hashCode =>
      bpm.hashCode ^
      timestamp.hashCode ^
      sensorLocation.hashCode ^
      batteryLevel.hashCode ^
      sensorContactSupported.hashCode ^
      sensorContactActive.hashCode ^
      rrIntervals.fold(0, (a, b) => a ^ b.hashCode);

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
