import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/hr_measurement.dart';

/// Repository contract for streaming standardized heart rate telemetries.
abstract class HeartRateRepository {
  /// Continuous stream of parsed real-time heart rate and R-R interval metrics.
  Stream<HrMeasurement> get heartRateStream;
}
