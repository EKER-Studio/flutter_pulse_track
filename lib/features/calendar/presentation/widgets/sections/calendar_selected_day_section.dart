import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Section showing the workout sessions recorded on the currently selected date.
class CalendarSelectedDaySection extends StatelessWidget {
  /// The date currently selected in the calendar.
  final DateTime selectedDate;

  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  const CalendarSelectedDaySection({
    super.key,
    required this.selectedDate,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dayLabel = DateFormat.yMMMMEEEEd(locale).format(selectedDate);

    final daySessions = sessions.where((s) {
      return s.startTime.year == selectedDate.year &&
          s.startTime.month == selectedDate.month &&
          s.startTime.day == selectedDate.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dayLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (daySessions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${daySessions.length}',
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (daySessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.fitness_center_outlined,
                  size: 36,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.calendarNoWorkouts,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...daySessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _WorkoutDayCard(session: session),
            ),
          ),
      ],
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutDayCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final duration = formatWorkoutDuration(session.startTime, session.endTime);
    final startTimeFormatted = DateFormat.Hm().format(session.startTime);
    final deviceName = session.deviceName.isEmpty
        ? l10n.unknownSensorName
        : session.deviceName;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/history/details/${session.id}', extra: session);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.accentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$startTimeFormatted • $duration',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.workoutMetricsSummary(
                        session.avgBpm,
                        session.maxBpm,
                      ),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deviceName,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
