import '../../../../workout/infrastructure/models/isar_hr_measurement.dart';
import '../../../domain/models/hr_measurement.dart';

/// Data mapper translating domain-level heart rate measurements into local Isar infrastructure models and vice versa.
class HrMeasurementMapper {
  /// Converts a pure Domain entity into an Infrastructure Isar embedded model.
  static IsarHrSample toIsarSample(HrMeasurement domain) {
    return IsarHrSample()
      ..bpm = domain.bpm
      ..rrIntervals = List<double>.from(domain.rrIntervals)
      ..timestamp = domain.timestamp;
  }

  /// Converts an Infrastructure Isar model back into a pure Domain entity.
  static HrMeasurement toDomain(IsarHrSample isar) {
    return HrMeasurement(
      bpm: isar.bpm,
      rrIntervals: List<double>.from(isar.rrIntervals),
      timestamp: isar.timestamp,
    );
  }
}
