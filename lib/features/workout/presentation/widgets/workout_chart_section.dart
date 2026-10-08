import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_zones.dart';
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

class _WaveformChartContainer extends StatefulWidget {
  final WorkoutSession session;

  const _WaveformChartContainer({required this.session});

  @override
  State<_WaveformChartContainer> createState() =>
      _WaveformChartContainerState();
}

class _WaveformChartContainerState extends State<_WaveformChartContainer> {
  double? _scrubFraction;

  void _handleScrub(Offset localPosition, double chartWidth) {
    if (chartWidth <= 0) return;
    final fraction = (localPosition.dx / chartWidth).clamp(0.0, 1.0);
    setState(() {
      _scrubFraction = fraction;
    });
  }

  void _clearScrub() {
    if (_scrubFraction != null) {
      setState(() {
        _scrubFraction = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = widget.session;
    final samples = session.bpmSamples;

    int? scrubBpm;
    Duration? scrubOffset;
    if (_scrubFraction != null && samples.isNotEmpty) {
      final sampleIndex = (_scrubFraction! * (samples.length - 1))
          .round()
          .clamp(0, samples.length - 1);
      scrubBpm = samples[sampleIndex];
      if (session.endTime != null) {
        final totalDuration = session.endTime!.difference(session.startTime);
        scrubOffset = Duration(
          milliseconds:
              (totalDuration.inMilliseconds *
                      (sampleIndex /
                          (samples.length > 1 ? samples.length - 1 : 1)))
                  .round(),
        );
      }
    }

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (details) => _handleScrub(
                        details.localPosition,
                        constraints.maxWidth,
                      ),
                      onPanUpdate: (details) => _handleScrub(
                        details.localPosition,
                        constraints.maxWidth,
                      ),
                      onPanEnd: (_) => _clearScrub(),
                      onPanCancel: _clearScrub,
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: BpmChart(
                          samples: session.bpmSamples,
                          startTime: session.startTime,
                          endTime: session.endTime,
                          emptyLabel: l10n.chartNoData,
                          scrubFraction: _scrubFraction,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (scrubBpm != null)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkerBackground.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getZoneColor(scrubBpm),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$scrubBpm BPM',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (scrubOffset != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '+${_formatDuration(scrubOffset)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
