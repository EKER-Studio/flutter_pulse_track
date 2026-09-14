import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal dialog for configuring the user's default maximum heart rate in BPM.
class MaxHrSelectionDialog extends StatefulWidget {
  /// Currently configured maximum heart rate.
  final int currentMaxHr;

  /// Callback when a new valid value is confirmed.
  final ValueChanged<int> onConfirmed;

  /// Creates a [MaxHrSelectionDialog].
  const MaxHrSelectionDialog({
    required this.currentMaxHr,
    required this.onConfirmed,
    super.key,
  });

  /// Displays the dialog modally.
  static Future<void> show(
    BuildContext context, {
    required int currentMaxHr,
    required ValueChanged<int> onConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => MaxHrSelectionDialog(
        currentMaxHr: currentMaxHr,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<MaxHrSelectionDialog> createState() => _MaxHrSelectionDialogState();
}

class _MaxHrSelectionDialogState extends State<MaxHrSelectionDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentMaxHr.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 50 || parsed > 240) {
      setState(() {
        _errorMessage = 'Please enter a value between 50 and 240';
      });
      return;
    }

    widget.onConfirmed(parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.settingsMaxHrDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            autofocus: true,
            decoration: InputDecoration(
              suffixText: 'BPM',
              hintText: '190',
              errorText: _errorMessage,
              helperText: l10n.settingsMaxHrDialogHint,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
