import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/settings/domain/services/csv_workout_importer.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal dialog summarizing the findings of a workout CSV analysis before importing.
class CsvImportPreviewDialog extends StatelessWidget {
  /// The audit summary produced by [CsvWorkoutImporter].
  final CsvWorkoutImportAnalysis analysis;

  const CsvImportPreviewDialog({required this.analysis, super.key});

  /// Displays the dialog modally and returns true if user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required CsvWorkoutImportAnalysis analysis,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CsvImportPreviewDialog(analysis: analysis),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final dateFormat = DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    );

    String? dateRangeText;
    final earliestDate = analysis.earliestDate;
    final latestDate = analysis.latestDate;
    if (earliestDate != null && latestDate != null) {
      final start = dateFormat.format(earliestDate);
      final end = dateFormat.format(latestDate);
      dateRangeText = start == end
          ? start
          : l10n.csvPreviewDateRange(start, end);
    }

    final validCount = analysis.validSessions.length;
    final skippedCount = analysis.skippedRowCount;

    return AlertDialog(
      title: Text(l10n.csvPreviewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentBlue.withAlpha(80)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.csvPreviewSessionsCount(validCount),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (dateRangeText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    dateRangeText,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          if (skippedCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorRed.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.csvPreviewSkippedRows(skippedCount),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: validCount > 0
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(l10n.csvPreviewConfirmImport(validCount)),
        ),
      ],
    );
  }
}
