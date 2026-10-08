import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/theme_selection_dialog.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for theme and visual appearance configuration.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.settingsSectionAppearance),
        SettingsTile(
          icon: Icons.brightness_medium_rounded,
          title: l10n.settingsTheme,
          subtitle: _themeModeLabel(context, settings.themeMode),
          onTap: () => ThemeSelectionDialog.show(
            context,
            currentMode: settings.themeMode,
            onSelected: (mode) =>
                ref.read(appSettingsProvider.notifier).updateTheme(mode),
          ),
        ),
      ],
    );
  }

  String _themeModeLabel(BuildContext context, AppThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      AppThemeMode.system => l10n.settingsThemeSystem,
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
    };
  }
}
