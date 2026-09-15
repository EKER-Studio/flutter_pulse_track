import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Destructive confirmation dialog before wiping all workout history.
class WipeDataDialog extends StatelessWidget {
  /// Creates a [WipeDataDialog].
  const WipeDataDialog({super.key});

  /// Displays the dialog modally and returns true if user confirmed.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const WipeDataDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: const Icon(
        Icons.warning_rounded,
        color: AppColors.errorRed,
        size: 36,
      ),
      title: Text(l10n.wipeDataDialogTitle),
      content: Text(l10n.wipeDataDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.wipeDataConfirm),
        ),
      ],
    );
  }
}
