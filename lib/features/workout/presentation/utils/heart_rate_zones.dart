import 'package:flutter/material.dart';

/// Heart rate zone definitions and utilities based on a configurable max heart rate.
class HeartRateZone {
  const HeartRateZone({
    required this.label,
    required this.minPercent,
    required this.maxPercent,
    required this.color,
  });

  /// Short display name for the zone (e.g. "Z1").
  final String label;

  /// Lower bound of the zone as a fraction of max heart rate (0.0–1.0).
  final double minPercent;

  /// Upper bound of the zone as a fraction of max heart rate (0.0–1.0).
  final double maxPercent;

  /// Visual color used to represent this zone on charts and legends.
  final Color color;
}

/// Palette of zone colors ordered from Z1 through Z5.
const List<Color> kZoneColors = [
  Color(0xFF4D96FF),
  Color(0xFF6BCB77),
  Color(0xFFFFD93D),
  Color(0xFFFF9F45),
  Color(0xFFFF6B6B),
];

/// Default assumed maximum heart rate used when none is provided.
const int kDefaultMaxHr = 190;

const List<HeartRateZone> kHeartRateZones = [
  HeartRateZone(label: 'Z1', minPercent: 0.50, maxPercent: 0.60, color: Color(0xFF4D96FF)),
  HeartRateZone(label: 'Z2', minPercent: 0.60, maxPercent: 0.70, color: Color(0xFF6BCB77)),
  HeartRateZone(label: 'Z3', minPercent: 0.70, maxPercent: 0.80, color: Color(0xFFFFD93D)),
  HeartRateZone(label: 'Z4', minPercent: 0.80, maxPercent: 0.90, color: Color(0xFFFF9F45)),
  HeartRateZone(label: 'Z5', minPercent: 0.90, maxPercent: 1.00, color: Color(0xFFFF6B6B)),
];

/// Returns the zone index (1-5) for a given bpm value.
int getZoneIndex(int bpm, {int maxHr = kDefaultMaxHr}) {
  final percentage = (bpm / maxHr * 100).clamp(0.0, 100.0);
  for (var i = 0; i < kHeartRateZones.length; i++) {
    final zone = kHeartRateZones[i];
    if (percentage >= zone.minPercent * 100 && percentage < zone.maxPercent * 100) {
      return i + 1;
    }
  }
  if (percentage >= 100) return 5;
  return 1;
}

/// Returns the color for a given bpm value.
Color getZoneColor(int bpm, {int maxHr = kDefaultMaxHr}) {
  final index = getZoneIndex(bpm, maxHr: maxHr);
  return kZoneColors[index - 1];
}
