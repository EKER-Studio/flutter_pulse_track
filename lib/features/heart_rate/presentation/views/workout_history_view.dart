import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/usecases/delete_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_workout_history_usecase.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Reactive workout history screen that displays every persisted
/// [WorkoutSession], sorted by start time descending, via
/// [watchWorkoutHistoryStreamProvider].
class WorkoutHistoryView extends ConsumerWidget {
  const WorkoutHistoryView({super.key});

  /// Builds the workout history list view using [context] and [ref].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                    label: const Text('Retry'),
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
                    } catch (e, st) {
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

  /// Renders a centered empty-state message when no workout sessions exist.
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noWorkoutsTitle,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noWorkoutsDescription,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
    final duration = _formatDuration(session.startTime, session.endTime);
    final formattedDate = _formatDate(l10n, session.startTime);
    final deviceName = session.deviceName.isEmpty
        ? l10n.unknownSensorName
        : session.deviceName;

    return Material(
      color: Colors.transparent,
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
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
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

  /// Builds a vertical metric pair showing a bold numeric [value] above a [label].
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

  /// Returns a relative date string ("Today, HH:mm", "Yesterday…", or "Mon, MMM DD, HH:mm").
  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return l10n.todayPrefix(intl.DateFormat.Hm().format(date));
    } else if (difference == 1) {
      return l10n.yesterdayPrefix(intl.DateFormat.Hm().format(date));
    } else {
      return '${intl.DateFormat.EEEE().format(date)}, ${intl.DateFormat.Md().format(date)} at ${intl.DateFormat.Hm().format(date)}';
    }
  }

  /// Formats the elapsed time between [start] and [end] into a compact "Xh Ym" string.
  String _formatDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
