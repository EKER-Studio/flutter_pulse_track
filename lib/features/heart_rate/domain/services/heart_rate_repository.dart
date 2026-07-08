import '../models/hr_measurement.dart';

abstract class HeartRateRepository {
  Stream<HrMeasurement> get heartRateStream;
}
