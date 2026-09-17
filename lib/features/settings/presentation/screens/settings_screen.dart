import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/settings/domain/models/app_theme_mode.dart';
import 'package:pulse_track/features/settings/infrastructure/services/csv_workout_import_service.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/csv_import_preview_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/max_hr_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/theme_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/wipe_data_dialog.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/core/integrations/biometrics/biometric_service.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Screen providing user controls for appearance, workout metrics,
/// data import/export/wipe operations, and app attribution.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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

  String _themeModeLabel(BuildContext context, AppThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      AppThemeMode.system => l10n.settingsThemeSystem,
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
    };
  }

  Future<void> _exportWorkouts(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final sessions = await ref.read(watchWorkoutHistoryStreamProvider.future);

    if (sessions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.csvExportEmpty)));
      }
      return;
    }

    try {
      await ref
          .read(workoutExportShareServiceProvider)
          .exportAndShareAllSessions(
            sessions,
            shareText: l10n.workoutShareBulkText(sessions.length.toString()),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.csvExportSuccess)));
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutDetailsExportFailed(e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _importWorkouts(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      final analysis = await ref
          .read(csvWorkoutImportServiceProvider)
          .pickAndParseCsv();
      if (analysis == null) return;

      if (analysis.validSessions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.csvImportNoValidData)));
        }
        return;
      }

      if (!context.mounted) return;
      final confirmed = await CsvImportPreviewDialog.show(
        context,
        analysis: analysis,
      );
      if (!confirmed) return;

      final repository = ref.read(workoutPersistenceRepositoryProvider);
      final batch = analysis.validSessions
          .map(
            (s) => WorkoutSession(
              id: 0,
              startTime: s.startTime,
              endTime: s.endTime ?? s.startTime,
              avgBpm: s.avgBpm,
              maxBpm: s.maxBpm,
              bpmSamples: s.bpmSamples,
              sensorLocationIndex: s.sensorLocationIndex,
              deviceMacAddress: s.deviceMacAddress,
              deviceName: s.deviceName,
            ),
          )
          .toList();
      await repository.saveWorkoutSessionsBatch(batch);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.csvImportSuccess(analysis.validSessions.length)),
          ),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutDetailsExportFailed(e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _wipeData(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WipeDataDialog.show(context);
    if (!confirmed) return;

    final sessions = await ref.read(watchWorkoutHistoryStreamProvider.future);
    final repository = ref.read(workoutPersistenceRepositoryProvider);
    await repository.deleteWorkoutSessions(sessions.map((s) => s.id).toList());

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.wipeDataSuccess)));
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
    final settings = ref.watch(appSettingsProvider);
    final packageInfo = _packageInfo;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Appearance section
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
          const SizedBox(height: 16),

          // Workout metrics section
          SettingsSectionHeader(title: l10n.settingsSectionWorkout),
          SettingsTile(
            icon: Icons.favorite_outline_rounded,
            title: l10n.settingsDefaultMaxHr,
            subtitle: l10n.settingsDefaultMaxHrSubtitle(settings.defaultMaxHr),
            onTap: () => MaxHrSelectionDialog.show(
              context,
              currentMaxHr: settings.defaultMaxHr,
              onConfirmed: (maxHr) =>
                  ref.read(appSettingsProvider.notifier).updateMaxHr(maxHr),
            ),
          ),
          const SizedBox(height: 16),

          // Data management section
          SettingsSectionHeader(title: l10n.settingsSectionData),
          SettingsTile(
            icon: Icons.upload_rounded,
            title: l10n.settingsExportAllWorkouts,
            subtitle: l10n.settingsExportAllWorkoutsSubtitle,
            onTap: () => _exportWorkouts(context),
          ),
          SettingsTile(
            icon: Icons.download_rounded,
            title: l10n.settingsImportWorkouts,
            subtitle: l10n.settingsImportWorkoutsSubtitle,
            onTap: () => _importWorkouts(context),
          ),
          SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.errorRed,
            title: l10n.settingsWipeData,
            titleColor: AppColors.errorRed,
            subtitle: l10n.settingsWipeDataSubtitle,
            onTap: () => _wipeData(context),
          ),
          const SizedBox(height: 16),

          // Security section
          SettingsSectionHeader(title: l10n.biometricLock),
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.biometricLock,
            subtitle: l10n.biometricDesc,
            trailing: Switch(
              value: settings.isBiometricLockEnabled,
              onChanged: (enabled) async {
                if (enabled) {
                  final result = await BiometricService.instance.authenticate(
                    localizedReason: l10n.biometricAuthReason,
                    authMessages: BiometricService.createAuthMessages(l10n),
                  );
                  if (result == BiometricAuthResult.success) {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .updateBiometricLock(true);
                    ref.read(appSettingsProvider.notifier).setLocked(true);
                  } else if (BiometricService.isTerminalFailure(result) ||
                      result == BiometricAuthResult.notAvailable) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.biometricsNotAvailable)),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.biometricAuthFailed)),
                      );
                    }
                  }
                } else {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .updateBiometricLock(false);
                  ref.read(appSettingsProvider.notifier).setLocked(false);
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // About & support section
          SettingsSectionHeader(title: l10n.settingsSectionAbout),
          SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsVersion,
            subtitle: packageInfo != null
                ? 'v${packageInfo.version} (${packageInfo.buildNumber})'
                : '...',
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
            onTap: () => _launchUrl(
              'https://github.com/piotrekert90/flutter_pulse_track',
            ),
          ),
          SettingsTile(
            icon: Icons.help_outline_rounded,
            title: l10n.settingsSupport,
            subtitle: l10n.settingsSupportSubtitle,
            onTap: () => _launchUrl(
              'https://github.com/piotrekert90/flutter_pulse_track/issues',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
