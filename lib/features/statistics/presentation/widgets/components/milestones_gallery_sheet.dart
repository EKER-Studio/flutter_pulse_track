import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/statistics/domain/entities/milestone.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/components/milestone_badge.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal bottom sheet showcasing all milestone badges with detailed progress and unlock status.
class MilestonesGallerySheet extends StatelessWidget {
  /// All evaluated milestones.
  final List<Milestone> milestones;

  const MilestonesGallerySheet({super.key, required this.milestones});

  /// Displays the gallery bottom sheet.
  static Future<void> show(BuildContext context, List<Milestone> milestones) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MilestonesGallerySheet(milestones: milestones),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlockedCount = milestones.where((m) => m.isUnlocked).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.milestonesGallery,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unlockedCount / ${milestones.length}',
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  return MilestoneBadge(
                    milestone: milestone,
                    onTap: () => _showMilestoneDetails(context, milestone),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMilestoneDetails(BuildContext context, Milestone milestone) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceBackground,
          title: Text(
            milestone.title,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                milestone.description,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (milestone.isUnlocked)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.accentGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: milestone.progress,
                      backgroundColor: AppColors.badgeBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progress: ${(milestone.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.accentBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}
