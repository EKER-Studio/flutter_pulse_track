import 'package:pulse_track/core/presentation/theme/app_colors.dart';
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
  AppColors.hrZone1,
  AppColors.hrZone2,
  AppColors.hrZone3,
  AppColors.hrZone4,
  AppColors.hrZone5,
];

/// Default assumed maximum heart rate used when none is provided.
const int kDefaultMaxHr = 190;

/// Standard list of 5 target heart rate intensity zones.
const List<HeartRateZone> kHeartRateZones = [
  HeartRateZone(
    label: 'Z1',
    minPercent: 0.50,
    maxPercent: 0.60,
    color: AppColors.hrZone1,
  ),
  HeartRateZone(
    label: 'Z2',
    minPercent: 0.60,
    maxPercent: 0.70,
    color: AppColors.hrZone2,
  ),
  HeartRateZone(
    label: 'Z3',
    minPercent: 0.70,
    maxPercent: 0.80,
    color: AppColors.hrZone3,
  ),
  HeartRateZone(
    label: 'Z4',
    minPercent: 0.80,
    maxPercent: 0.90,
    color: AppColors.hrZone4,
  ),
  HeartRateZone(
    label: 'Z5',
    minPercent: 0.90,
    maxPercent: 1.00,
    color: AppColors.hrZone5,
  ),
];

/// Returns the zone index (1-5) for a given [bpm] value and optional [maxHr].
int getZoneIndex(int bpm, {int maxHr = kDefaultMaxHr}) {
  final percentage = (bpm / maxHr * 100).clamp(0.0, 100.0);
  for (var i = 0; i < kHeartRateZones.length; i++) {
    final zone = kHeartRateZones[i];
    if (percentage >= zone.minPercent * 100 &&
        percentage < zone.maxPercent * 100) {
      return i + 1;
    }
  }
  if (percentage >= 100) return 5;
  return 1;
}

/// Returns the zone [Color] for a given [bpm] value and optional [maxHr].
Color getZoneColor(int bpm, {int maxHr = kDefaultMaxHr}) {
  final index = getZoneIndex(bpm, maxHr: maxHr);
  return kZoneColors[index - 1];
}
