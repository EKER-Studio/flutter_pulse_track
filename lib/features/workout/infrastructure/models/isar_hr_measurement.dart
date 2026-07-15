import 'package:isar_community/isar.dart';

part 'isar_hr_measurement.g.dart';

/// Isar collection representing a single, complete workout tracking session.
@collection
class HrWorkoutSession {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime startTime;

  late DateTime endTime;

  /// Embedded list of all heart rate samples recorded during this specific session.
  List<IsarHrSample> samples = [];
}

/// Embedded data structure representing an individual heart rate data point.
@embedded
class IsarHrSample {
  late int bpm;

  /// Raw R-R intervals associated with this specific pulse measurement.
  List<double> rrIntervals = [];

  late DateTime timestamp;
}
