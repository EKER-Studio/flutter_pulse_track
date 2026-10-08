import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// 2x2 grid displaying key summary metrics for a workout session.
///
/// Shows average BPM, peak BPM, duration, and recorded sample count.
class WorkoutSummaryGrid extends StatelessWidget {
  /// The workout session whose metrics are displayed.
  final WorkoutSession session;

  /// Pre-formatted duration string.
  final String duration;

  const WorkoutSummaryGrid({
    super.key,
    required this.session,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutDetailsSummary,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _WorkoutSummaryTile(
                label: l10n.workoutDetailsAvgBpm,
                value: '${session.avgBpm}',
                icon: Icons.favorite,
                iconColor: AppColors.statIconAvg,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _WorkoutSummaryTile(
                label: l10n.workoutDetailsPeakBpm,
                value: '${session.maxBpm}',
                icon: Icons.favorite_border,
                iconColor: AppColors.statIconPeak,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _WorkoutSummaryTile(
                label: l10n.workoutDetailsDuration,
                value: duration,
                icon: Icons.timer,
                iconColor: AppColors.statIconDuration,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _WorkoutSummaryTile(
                label: l10n.workoutDetailsSamples,
                value: '${session.bpmSamples.length}',
                icon: Icons.show_chart,
                iconColor: AppColors.statIconSamples,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutSummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _WorkoutSummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            ExcludeSemantics(child: Icon(icon, color: iconColor, size: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
