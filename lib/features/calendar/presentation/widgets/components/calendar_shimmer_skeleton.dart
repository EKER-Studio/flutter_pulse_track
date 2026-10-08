import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Skeleton placeholder displayed while workout history data is being fetched.
class CalendarShimmerSkeleton extends StatelessWidget {
  const CalendarShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 24,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.badgeBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 35,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (_, _) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
        ),
      ],
    );
  }
}
