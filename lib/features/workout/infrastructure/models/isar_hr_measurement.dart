import 'package:isar_community/isar.dart';

part 'isar_hr_measurement.g.dart';

/// Isar collection representing a single, complete workout tracking session.
///
/// Stores a lightweight snapshot of BPM and R-R interval samples captured during
/// a continuous workout. Prefer [WorkoutSessionDto] for sessions that require
/// pre-computed aggregates (avg/max BPM, device metadata).
@collection
class HrWorkoutSession {
  /// Auto-incremented primary key managed by Isar.
  Id id = Isar.autoIncrement;

  /// UTC timestamp marking the beginning of the workout session.
  @Index(type: IndexType.value)
  late DateTime startTime;

  /// UTC timestamp marking the end of the workout session.
  late DateTime endTime;

  /// Embedded list of all heart rate samples recorded during this specific session.
  List<IsarHrSample> samples = [];
}

/// Embedded data structure representing an individual heart rate data point.
///
/// Corresponds to one parsed BLE Heart Rate Measurement packet. Stored inline
/// within [HrWorkoutSession.samples] to avoid extra Isar object lookups.
@embedded
class IsarHrSample {
  /// Instantaneous heart rate in beats per minute.
  late int bpm;

  /// Raw R-R intervals associated with this specific pulse measurement.
  List<double> rrIntervals = [];

  /// UTC timestamp at which this sample was captured by the sensor.
  late DateTime timestamp;
}
