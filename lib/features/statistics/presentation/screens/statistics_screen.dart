import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/clamped_layout.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/components/statistics_shimmer_skeleton.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/habits_activity_card.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/milestones_card.dart';
import 'package:pulse_track/features/statistics/presentation/widgets/sections/period_comparison_card.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Screen presenting workout statistics, comparative performance, habits, and milestone badges.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.statisticsTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accentBlue,
        onRefresh: () async {
          ref.invalidate(watchWorkoutHistoryStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ClampedLayout(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: historyAsync.when(
              loading: () => const StatisticsShimmerSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    err.toString(),
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ),
              data: (sessions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PeriodComparisonCard(sessions: sessions),
                    const SizedBox(height: 16),
                    HabitsActivityCard(sessions: sessions),
                    const SizedBox(height: 16),
                    MilestonesCard(sessions: sessions),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
