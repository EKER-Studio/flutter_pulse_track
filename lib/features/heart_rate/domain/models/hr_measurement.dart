class HrMeasurement {
  final int bpm;

  /// R-R intervals stored in seconds to closely align with standard sport metrics and HRV analysis.
  final List<double> rrIntervals;
  final DateTime timestamp;

  const HrMeasurement({
    required this.bpm,
    required this.rrIntervals,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HrMeasurement &&
          runtimeType == other.runtimeType &&
          bpm == other.bpm &&
          timestamp == other.timestamp &&
          _listEquals(rrIntervals, other.rrIntervals);

  @override
  int get hashCode =>
      bpm.hashCode ^
      timestamp.hashCode ^
      rrIntervals.fold(0, (a, b) => a ^ b.hashCode);

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
