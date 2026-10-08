import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for app version, source code, licenses, and support links.
class AboutSupportSection extends StatefulWidget {
  const AboutSupportSection({super.key});

  @override
  State<AboutSupportSection> createState() => _AboutSupportSectionState();
}

class _AboutSupportSectionState extends State<AboutSupportSection> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packageInfo = _packageInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.settingsSectionAbout),
        SettingsTile(
          icon: Icons.info_outline_rounded,
          title: l10n.settingsVersion,
          subtitle: packageInfo != null
              ? 'v${packageInfo.version} (${packageInfo.buildNumber})'
              : '...',
        ),
        SettingsTile(
          icon: Icons.star_outline_rounded,
          title: l10n.settingsRateApp,
          subtitle: l10n.settingsRateAppSubtitle,
          onTap: () => _launchUrl(
            'https://play.google.com/store/apps/details?id=com.ekerstudio.pulsetrack',
          ),
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: l10n.settingsLicenses,
          subtitle: l10n.settingsLicensesSubtitle,
          onTap: () => context.push('/settings/licenses'),
        ),
        SettingsTile(
          icon: Icons.code_rounded,
          title: l10n.settingsSourceCode,
          subtitle: l10n.settingsSourceCodeSubtitle,
          onTap: () =>
              _launchUrl('https://github.com/piotrekert90/flutter_pulse_track'),
        ),
        SettingsTile(
          icon: Icons.help_outline_rounded,
          title: l10n.settingsSupport,
          subtitle: l10n.settingsSupportSubtitle,
          onTap: () => _launchUrl(
            'https://github.com/piotrekert90/flutter_pulse_track/issues',
          ),
        ),
      ],
    );
  }
}
