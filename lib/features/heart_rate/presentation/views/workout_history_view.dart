import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/usecases/delete_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_workout_history_usecase.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

/// Reactive workout history screen that displays every persisted
/// [WorkoutSession], sorted by start time descending, via
/// [watchWorkoutHistoryStreamProvider].
class WorkoutHistoryView extends ConsumerWidget {
  /// Creates a [WorkoutHistoryView] instance.
  const WorkoutHistoryView({super.key});

  /// Builds the workout history list view using [context] and [ref].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Workout History',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              child: Text(
                'Unable to load workout history. Please try again later.',
                style: TextStyle(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState();
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
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  color: AppColors.errorRed,
                  child: const Icon(
                    Icons.delete,
                    color: AppColors.textPrimary,
                    size: 24,
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
                          const SnackBar(
                            content: Text(
                              'Unable to delete session. Please try again.',
                            ),
                          ),
                        );
                      }
                      return false;
                    }
                  }
                  return true;
                },
                onDismissed: (_) {},
                child: _buildWorkoutCard(context, session),
              );
            },
          );
        },
      ),
    );
  }

  /// Renders a centered empty-state message when no workout sessions exist.
  Widget _buildEmptyState() {
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
              'No workouts recorded yet',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a heart rate monitoring session to see your workout history here.',
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
  Widget _buildWorkoutCard(BuildContext context, WorkoutSession session) {
    final duration = _formatDuration(session.startTime, session.endTime);
    final formattedDate = _formatDate(session.startTime);
    final deviceName = session.deviceName.isEmpty
        ? 'Unknown Sensor'
        : session.deviceName;

    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        label:
            'Workout on $formattedDate, duration $duration, sensor $deviceName. Average heart rate ${session.avgBpm} BPM, Peak heart rate ${session.maxBpm} BPM. Swipe left to delete.',
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkoutDetailsView(session: session),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        _buildMetricColumn('Avg BPM', '${session.avgBpm}'),
                        const SizedBox(width: 24),
                        _buildMetricColumn('Max BPM', '${session.maxBpm}'),
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
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return 'Today, ${intl.DateFormat.Hm().format(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${intl.DateFormat.Hm().format(date)}';
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
