import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Header displaying current month navigation controls and an optional "Today" jump button.
class CalendarMonthHeader extends StatelessWidget {
  /// The month currently focused and displayed.
  final DateTime focusedMonth;

  /// Callback when navigating to the previous month.
  final VoidCallback onPreviousMonth;

  /// Callback when navigating to the next month.
  final VoidCallback onNextMonth;

  /// Optional callback to jump back to the current date.
  final VoidCallback? onJumpToToday;

  const CalendarMonthHeader({
    super.key,
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onJumpToToday,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthYearLabel = DateFormat.yMMMM(locale).format(focusedMonth);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: AppColors.textPrimary,
          tooltip: l10n.calendarPreviousMonth,
          onPressed: onPreviousMonth,
        ),
        Expanded(
          child: Text(
            monthYearLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: AppColors.textPrimary,
          tooltip: l10n.calendarNextMonth,
          onPressed: onNextMonth,
        ),
        if (onJumpToToday != null)
          TextButton(
            onPressed: onJumpToToday,
            child: Text(
              l10n.calendarJumpToToday,
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
