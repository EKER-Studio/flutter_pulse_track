import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';
import 'package:pulse_track/features/statistics/domain/services/period_comparison_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Card presenting comparative workout volume and heart-rate metrics across rolling time windows.
class PeriodComparisonCard extends StatefulWidget {
  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  const PeriodComparisonCard({super.key, required this.sessions});

  @override
  State<PeriodComparisonCard> createState() => _PeriodComparisonCardState();
}

class _PeriodComparisonCardState extends State<PeriodComparisonCard> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final comparison = PeriodComparisonCalculator.compareRollingDays(
      sessions: widget.sessions,
      days: _selectedDays,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.accentBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.periodComparisonTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              _buildPeriodToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.accentBlue,
                  title: l10n.totalWorkouts,
                  currentValue: '${comparison.current.sessionCount}',
                  previousValue: '${comparison.previous.sessionCount}',
                  deltaText: comparison.sessionCountDelta >= 0
                      ? '+${comparison.sessionCountDelta}'
                      : '${comparison.sessionCountDelta}',
                  isPositive: comparison.sessionCountDelta >= 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.statIconDuration,
                  title: l10n.totalDuration,
                  currentValue: formatWorkoutDuration(
                    DateTime.now(),
                    DateTime.now().add(comparison.current.totalDuration),
                  ),
                  previousValue: formatWorkoutDuration(
                    DateTime.now(),
                    DateTime.now().add(comparison.previous.totalDuration),
                  ),
                  deltaText: comparison.durationDelta.inMinutes >= 0
                      ? '+${comparison.durationDelta.inMinutes}m'
                      : '${comparison.durationDelta.inMinutes}m',
                  isPositive: comparison.durationDelta.inMilliseconds >= 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.favorite,
                  iconColor: AppColors.accentRed,
                  title: l10n.avgHeartRate,
                  currentValue: comparison.current.avgBpm > 0
                      ? '${comparison.current.avgBpm.round()} BPM'
                      : '—',
                  previousValue: comparison.previous.avgBpm > 0
                      ? '${comparison.previous.avgBpm.round()} BPM'
                      : '—',
                  deltaText: comparison.avgBpmDelta != 0
                      ? '${comparison.avgBpmDelta > 0 ? "+" : ""}${comparison.avgBpmDelta.round()} BPM'
                      : null,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.statIconPeak,
                  title: l10n.peakHeartRate,
                  currentValue: comparison.current.maxBpm > 0
                      ? '${comparison.current.maxBpm} BPM'
                      : '—',
                  previousValue: comparison.previous.maxBpm > 0
                      ? '${comparison.previous.maxBpm} BPM'
                      : '—',
                  deltaText: null,
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(days: 7, label: '7D'),
          _buildToggleOption(days: 30, label: '30D'),
        ],
      ),
    );
  }

  Widget _buildToggleOption({required int days, required String label}) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.scaffoldBackground
                : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String currentValue,
    required String previousValue,
    required String? deltaText,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkerBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentValue,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prev: $previousValue',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
              if (deltaText != null)
                Text(
                  deltaText,
                  style: TextStyle(
                    color: isPositive
                        ? AppColors.accentGreen
                        : AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
