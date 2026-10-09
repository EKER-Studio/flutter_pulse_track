import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/statistics/domain/services/habits_calculator.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Card widget presenting habit consistency, daily streak counters, and monthly active days.
class HabitsActivityCard extends StatelessWidget {
  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  const HabitsActivityCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = HabitsCalculator.calculateSummary(sessions);

    final complianceRate = (summary.activeDaysInLast30 / 30.0).clamp(0.0, 1.0);

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
            children: [
              const Icon(
                Icons.repeat_rounded,
                color: AppColors.accentGreen,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.habitsTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStreakTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.accentOrange,
                  title: l10n.currentStreak,
                  value: '${summary.currentStreak} d',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.statIconPeak,
                  title: l10n.bestStreak,
                  value: '${summary.bestStreak} d',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.activeDaysLast30,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      l10n.habitsActiveDays(summary.activeDaysInLast30),
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: complianceRate,
                    minHeight: 6,
                    backgroundColor: AppColors.badgeBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
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
              Icon(icon, color: iconColor, size: 18),
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
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
