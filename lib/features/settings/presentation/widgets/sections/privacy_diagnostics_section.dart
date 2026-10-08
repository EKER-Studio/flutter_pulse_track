import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for crash reporting, analytics, and privacy policy links.
class PrivacyDiagnosticsSection extends ConsumerWidget {
  const PrivacyDiagnosticsSection({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.settingsSectionPrivacy),
        SettingsTile(
          icon: Icons.bug_report_outlined,
          title: l10n.settingsCrashReporting,
          subtitle: l10n.settingsCrashReportingSubtitle,
          trailing: Switch(
            value: settings.isCrashReportingEnabled,
            onChanged: (enabled) {
              ref
                  .read(appSettingsProvider.notifier)
                  .updateCrashReporting(enabled);
            },
          ),
        ),
        SettingsTile(
          icon: Icons.analytics_outlined,
          title: l10n.settingsAnalytics,
          subtitle: l10n.settingsAnalyticsSubtitle,
          trailing: Switch(
            value: settings.isAnalyticsEnabled,
            onChanged: (enabled) {
              ref.read(appSettingsProvider.notifier).updateAnalytics(enabled);
            },
          ),
        ),
        SettingsTile(
          icon: Icons.shield_outlined,
          title: l10n.settingsPrivacyPolicy,
          subtitle: l10n.settingsPrivacyPolicySubtitle,
          onTap: () => _launchUrl(
            'https://github.com/piotrekert90/flutter_pulse_track/blob/develop/doc/privacy_policy.md',
          ),
        ),
      ],
    );
  }
}
