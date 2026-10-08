import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_zones.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Displays a color-coded legend for the heart-rate training zones.
///
/// Each zone is rendered as a colored dot followed by its label and the
/// corresponding percentage range of maximum heart rate.
class HrZoneLegend extends StatelessWidget {
  const HrZoneLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final legend = kHeartRateZones
        .map(
          (z) =>
              '${z.label} ${l10n.percentRange((z.minPercent * 100).toInt(), (z.maxPercent * 100).toInt())}',
        )
        .join(', ');

    return Semantics(
      label: l10n.workoutDetailsZonesLegendSemantics(legend),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: List.generate(
          kHeartRateZones.length,
          (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: kHeartRateZones[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${kHeartRateZones[i].label} ${(kHeartRateZones[i].minPercent * 100).toInt()}%-${(kHeartRateZones[i].maxPercent * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
