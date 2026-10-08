import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/widgets/bpm_chart.dart';
import 'package:pulse_track/features/workout/presentation/widgets/hr_zone_legend.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Section rendering heart-rate waveform over time with zones legend or an empty fallback state.
class WorkoutChartSection extends StatelessWidget {
  /// The workout session whose heart rate data is rendered.
  final WorkoutSession session;

  const WorkoutChartSection({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasValidSamples =
        session.bpmSamples.isNotEmpty && !session.bpmSamples.any((s) => s <= 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutDetailsHeartRateOverTime,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12.0),
        if (!hasValidSamples)
          _EmptyChartContainer(session: session)
        else
          _WaveformChartContainer(session: session),
        if (hasValidSamples) ...[
          const SizedBox(height: 16.0),
          const HrZoneLegend(),
        ],
      ],
    );
  }
}

class _EmptyChartContainer extends StatelessWidget {
  final WorkoutSession session;

  const _EmptyChartContainer({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.workoutDetailsChartNoDataSemantics,
      child: Container(
        width: double.infinity,
        height: 250.0,
        decoration: BoxDecoration(
          color: AppColors.surfaceBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monitor_heart,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12.0),
              Text(
                l10n.workoutDetailsNoData,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEmptyDataReason(context, session),
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmptyDataReason(BuildContext context, WorkoutSession session) {
    final l = AppLocalizations.of(context);
    if (session.endTime == null) {
      return l.workoutDetailsNotCompleted;
    }
    if (session.bpmSamples.isEmpty) {
      return l.workoutDetailsSensorDisconnected;
    }
    return l.workoutDetailsNoValidData;
  }
}

class _WaveformChartContainer extends StatelessWidget {
  final WorkoutSession session;

  const _WaveformChartContainer({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.workoutDetailsChartWaveformSemantics(
        session.bpmSamples.length,
        session.avgBpm,
        session.maxBpm,
      ),
      child: Container(
        width: double.infinity,
        height: 250.0,
        decoration: BoxDecoration(
          color: AppColors.surfaceBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: CustomPaint(
            painter: BpmChart(
              samples: session.bpmSamples,
              startTime: session.startTime,
              endTime: session.endTime,
              emptyLabel: l10n.chartNoData,
            ),
          ),
        ),
      ),
    );
  }
}
