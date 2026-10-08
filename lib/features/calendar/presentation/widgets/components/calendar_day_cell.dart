import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Single interactive day cell rendered within [CalendarGrid].
class CalendarDayCell extends StatelessWidget {
  /// The specific calendar date represented by this cell.
  final DateTime date;

  /// Whether this day is currently selected by the user.
  final bool isSelected;

  /// Whether this day matches the current system date.
  final bool isToday;

  /// The list of workout sessions that took place on this day.
  final List<WorkoutSession> sessions;

  /// Callback invoked when this cell is tapped.
  final ValueChanged<DateTime> onSelected;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.sessions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkouts = sessions.isNotEmpty;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${date.day}, ${sessions.length} workouts',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => onSelected(date),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentBlue.withValues(alpha: 0.25)
                  : AppColors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.6),
                    )
                  : isSelected
                  ? Border.all(color: AppColors.accentBlue)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : isToday
                        ? AppColors.accentBlue
                        : AppColors.textSecondary,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                if (hasWorkouts)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
