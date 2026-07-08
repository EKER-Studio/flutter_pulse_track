import 'package:isar_community/isar.dart';

part 'isar_hr_measurement.g.dart';

@collection
class HrWorkoutSession {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime startTime;

  late DateTime endTime;

  // Embedded list of all heart rate samples recorded during this session
  late List<IsarHrSample> samples;
}

@embedded
class IsarHrSample {
  late int bpm;

  // Isar supports storing lists of doubles directly
  late List<double> rrIntervals;

  late DateTime timestamp;
}