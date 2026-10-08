import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Header card displaying date, duration badge, and sensor device name for a workout session.
class WorkoutHeaderCard extends StatelessWidget {
  /// The workout session displayed in this card.
  final WorkoutSession session;

  /// Pre-formatted duration string.
  final String duration;

  const WorkoutHeaderCard({
    super.key,
    required this.session,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formattedDate = formatAbsoluteDate(session.startTime);
    final deviceName = session.deviceName.isEmpty
        ? l10n.unknownSensor
        : session.deviceName;

    return Semantics(
      label: l10n.workoutDetailsHeaderSemantics(
        formattedDate,
        duration,
        deviceName,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceBackground,
          borderRadius: BorderRadius.circular(12.0),
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
                        borderRadius: BorderRadius.circular(6.0),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
