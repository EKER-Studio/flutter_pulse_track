import 'package:flutter/material.dart';

import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal dialog for choosing the application theme mode.
class ThemeSelectionDialog extends StatelessWidget {
  /// Currently active theme mode.
  final AppThemeMode currentMode;

  /// Callback when a new mode is selected.
  final ValueChanged<AppThemeMode> onSelected;

  /// Creates a [ThemeSelectionDialog].
  const ThemeSelectionDialog({
    required this.currentMode,
    required this.onSelected,
    super.key,
  });

  /// Displays the modal dialog.
  static Future<void> show(
    BuildContext context, {
    required AppThemeMode currentMode,
    required ValueChanged<AppThemeMode> onSelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ThemeSelectionDialog(
        currentMode: currentMode,
        onSelected: (mode) {
          onSelected(mode);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  String _modeLabel(BuildContext context, AppThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      AppThemeMode.system => l10n.settingsThemeSystem,
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SimpleDialog(
      title: Text(l10n.settingsTheme),
      children: [
        RadioGroup<AppThemeMode>(
          groupValue: currentMode,
          onChanged: (val) {
            if (val != null) onSelected(val);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in AppThemeMode.values)
                RadioListTile<AppThemeMode>(
                  title: Text(_modeLabel(context, mode)),
                  value: mode,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
