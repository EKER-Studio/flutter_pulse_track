import 'body_sensor_location.dart';

class HrMeasurement {
  final int bpm;

  /// R-R intervals stored in seconds to closely align with standard sport metrics and HRV analysis.
  final List<double> rrIntervals;
  final DateTime timestamp;

  /// Dynamic hardware placement location decoded via BLE GATT characteristic 0x2A38.
  final BodySensorLocation sensorLocation;

  const HrMeasurement({
    required this.bpm,
    required this.rrIntervals,
    required this.timestamp,
    this.sensorLocation = BodySensorLocation.unknown,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HrMeasurement &&
          runtimeType == other.runtimeType &&
          bpm == other.bpm &&
          timestamp == other.timestamp &&
          sensorLocation == other.sensorLocation &&
          _listEquals(rrIntervals, other.rrIntervals);

  @override
  int get hashCode =>
      bpm.hashCode ^
      timestamp.hashCode ^
      sensorLocation.hashCode ^
      rrIntervals.fold(0, (a, b) => a ^ b.hashCode);

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
