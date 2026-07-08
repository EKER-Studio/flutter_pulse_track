class HrMeasurement {
  final int bpm;
  final List<double> rrIntervals; // In seconds, to closely align with sport metrics
  final DateTime timestamp;

  const HrMeasurement({
    required this.bpm,
    required this.rrIntervals,
    required this.timestamp,
  });
}
