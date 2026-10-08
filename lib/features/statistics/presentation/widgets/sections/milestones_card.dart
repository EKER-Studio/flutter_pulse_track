import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/statistics/domain/services/milestone_calculator.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/components/milestone_badge.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/components/milestones_gallery_sheet.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Card previewing unlocked and upcoming milestone achievement badges with gallery trigger.
class MilestonesCard extends StatelessWidget {
  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  const MilestonesCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestones = MilestoneCalculator.evaluateMilestones(sessions);
    final previewMilestones = milestones.take(4).toList();

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
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.accentOrange,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.milestonesTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    MilestonesGallerySheet.show(context, milestones),
                child: Text(
                  l10n.viewAllMilestones,
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: previewMilestones.map((m) {
              return Expanded(
                child: MilestoneBadge(
                  milestone: m,
                  onTap: () => MilestonesGallerySheet.show(context, milestones),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
