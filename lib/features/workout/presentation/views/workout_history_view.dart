import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/status_state_view.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Reactive workout history screen that displays every persisted
/// [WorkoutSession], sorted by start time descending, via
/// [watchWorkoutHistoryStreamProvider].
class WorkoutHistoryView extends ConsumerWidget {
  const WorkoutHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.workoutHistoryAppBarTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
        error: (error, stackTrace) {
          log.e(
            'Failed to load workout history',
            error: error,
            stackTrace: stackTrace,
          );
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.unableToLoadHistory,
                    style: const TextStyle(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.invalidate(watchWorkoutHistoryStreamProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry_button_label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState(l10n);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            itemCount: sessions.length,
            separatorBuilder: (BuildContext _, int index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Dismissible(
                key: Key(session.id.toString()),
                direction: DismissDirection.endToStart,
                background: Semantics(
                  button: true,
                  label: l10n.deleteSessionLabel,
                  hint: l10n.deleteSessionHint,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    color: AppColors.errorRed,
                    constraints: const BoxConstraints(minHeight: 48),
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    try {
                      await ref
                          .read(deleteWorkoutSessionUseCaseProvider)
                          .call(session.id);
                      return true;
                    } on Object catch (e, st) {
                      log.e(
                        'Failed to delete session',
                        error: e,
                        stackTrace: st,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.unableToDeleteSession)),
                        );
                      }
                      return false;
                    }
                  }
                  return true;
                },
                onDismissed: (_) {},
                child: _buildWorkoutCard(context, l10n, session),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return StatusStateView(
      icon: Icons.fitness_center,
      iconColor: AppColors.textTertiary,
      title: l10n.noWorkoutsTitle,
      titleStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      subtitle: l10n.noWorkoutsDescription,
      scrollable: false,
    );
  }

  /// Builds a tappable card for a single workout session.
  ///
  /// Tapping navigates to [WorkoutDetailsView]. Swiping right dismisses
  /// and deletes the session from Isar.
  Widget _buildWorkoutCard(
    BuildContext context,
    AppLocalizations l10n,
    WorkoutSession session,
  ) {
    final duration = formatWorkoutDuration(session.startTime, session.endTime);
    final formattedDate = formatRelativeDate(l10n, session.startTime);
    final deviceName = session.deviceName.isEmpty
        ? l10n.unknownSensorName
        : session.deviceName;

    return Material(
      color: AppColors.transparent,
      child: Semantics(
        button: true,
        label: l10n.workoutCardLabel(formattedDate),
        hint: l10n.workoutCardHint(
          duration,
          deviceName,
          session.avgBpm,
          session.maxBpm,
        ),
        child: InkWell(
          onTap: () {
            context.push('/history/details/${session.id}', extra: session);
          },

          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            duration,
                            style: const TextStyle(
                              color: AppColors.accentBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMetricColumn(
                          l10n.avgBpmMetric,
                          '${session.avgBpm}',
                        ),
                        const SizedBox(width: 24),
                        _buildMetricColumn(
                          l10n.maxBpmMetric,
                          '${session.maxBpm}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }
}
