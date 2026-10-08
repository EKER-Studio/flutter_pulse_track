import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Sliver section rendering previously paired and saved BLE heart-rate sensors.
class SavedSensorsSection extends ConsumerWidget {
  const SavedSensorsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedProfilesAsync = ref.watch(
      watchSavedDeviceProfilesStreamProvider,
    );
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return savedProfilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bluetooth_connected,
                          color: AppColors.accentBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.savedSensorsSectionTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final profileName = profile.name.isEmpty
                            ? l10n.unknownSensorLabel
                            : profile.name;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Semantics(
                            button: true,
                            label: l10n.connectToSensor(profileName),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: ActionChip(
                                backgroundColor: AppColors.badgeBackground,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                avatar: const ExcludeSemantics(
                                  child: Icon(
                                    Icons.bluetooth_connected,
                                    color: AppColors.accentGreen,
                                    size: 14,
                                  ),
                                ),
                                label: Text(
                                  profileName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: () {
                                  final nameToPass = profile.name.isEmpty
                                      ? l10n.savedSensorFallbackName
                                      : profile.name;
                                  context.push(
                                    '/monitor?deviceId=${Uri.encodeComponent(profile.macAddress)}&deviceName=${Uri.encodeComponent(nameToPass)}',
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.accentRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.failedToLoadSavedSensors(error.toString()),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(watchSavedDeviceProfilesStreamProvider),
                  child: Text(l10n.retry_button_label),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}
