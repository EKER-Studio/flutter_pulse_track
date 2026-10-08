import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Row of abbreviated weekday headers displayed above the calendar grid.
class CalendarWeekdayHeader extends StatelessWidget {
  const CalendarWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    // Monday of the current week (weekday 1)
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final weekdayNames = List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return DateFormat.E(locale).format(day);
    });

    return Row(
      children: weekdayNames.map((name) {
        return Expanded(
          child: Center(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
