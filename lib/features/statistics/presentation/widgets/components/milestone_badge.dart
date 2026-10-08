import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/statistics/domain/entities/milestone.dart';

/// Interactive circular badge visual representing a single [Milestone].
class MilestoneBadge extends StatelessWidget {
  /// The milestone represented by this badge.
  final Milestone milestone;

  /// Optional tap handler to display milestone details.
  final VoidCallback? onTap;

  const MilestoneBadge({super.key, required this.milestone, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = milestone.isUnlocked;

    return Semantics(
      button: true,
      label: '${milestone.title}: ${isUnlocked ? "Unlocked" : "Locked"}',
      hint: milestone.description,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? AppColors.accentOrange.withValues(alpha: 0.2)
                      : AppColors.surfaceBackground,
                  border: Border.all(
                    color: isUnlocked
                        ? AppColors.accentOrange
                        : AppColors.borderSubtle,
                    width: isUnlocked ? 2.0 : 1.0,
                  ),
                ),
                child: Icon(
                  _resolveMilestoneIcon(milestone.type),
                  color: isUnlocked
                      ? AppColors.accentOrange
                      : AppColors.textTertiary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                milestone.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _resolveMilestoneIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.firstWorkout:
        return Icons.flag_rounded;
      case MilestoneType.workouts5:
        return Icons.front_hand_rounded;
      case MilestoneType.workouts10:
        return Icons.star_rounded;
      case MilestoneType.workouts25:
        return Icons.workspace_premium_rounded;
      case MilestoneType.workouts50:
        return Icons.military_tech_rounded;
      case MilestoneType.workouts100:
        return Icons.emoji_events_rounded;
      case MilestoneType.streak3:
      case MilestoneType.streak7:
      case MilestoneType.streak14:
      case MilestoneType.streak30:
        return Icons.local_fire_department_rounded;
      case MilestoneType.endurance60:
      case MilestoneType.endurance90:
        return Icons.timer_rounded;
      case MilestoneType.earlyBird:
        return Icons.wb_sunny_rounded;
      case MilestoneType.nightOwl:
        return Icons.nightlight_round;
      case MilestoneType.weekendWarrior:
        return Icons.fitness_center_rounded;
    }
  }
}
