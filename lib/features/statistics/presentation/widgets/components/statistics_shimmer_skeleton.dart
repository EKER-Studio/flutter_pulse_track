import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Skeleton placeholder displayed while workout statistics are being calculated.
class StatisticsShimmerSkeleton extends StatelessWidget {
  const StatisticsShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSkeletonCard(height: 200),
        const SizedBox(height: 16),
        _buildSkeletonCard(height: 140),
        const SizedBox(height: 16),
        _buildSkeletonCard(height: 140),
      ],
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
    );
  }
}
