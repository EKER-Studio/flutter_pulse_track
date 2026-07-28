import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/l10n/app_localizations.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_saved_device_profiles_usecase.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';

/// Central dashboard hub for the heart rate monitoring application.
///
/// Displays a reactive list of saved sensor profiles (via
/// [watchSavedDeviceProfilesStreamProvider]) for instant direct-connect,
/// alongside navigation placeholders for future features (Workout History,
/// Build in Public Guide).
class HrHomeView extends ConsumerWidget {
  const HrHomeView({super.key});

  /// Builds the home dashboard hub layout using [context] and [ref].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedProfilesAsync = ref.watch(
      watchSavedDeviceProfilesStreamProvider,
    );
    var l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.homeTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Builder(
        builder: (context) {
          final savedProfiles = savedProfilesAsync.maybeWhen(
            data: (profiles) => profiles,
            orElse: () => <DeviceProfile>[],
          );

          return CustomScrollView(
            slivers: [
              // --- SAVED SENSORS SECTION ---
              if (savedProfiles.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceBackground,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              itemCount: savedProfiles.length,
                              itemBuilder: (context, index) {
                                final profile = savedProfiles[index];
                                final profileName = profile.name.isEmpty
                                    ? l10n.unknownSensorLabel
                                    : profile.name;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Semantics(
                                    button: true,
                                    label: l10n.connectToSensor(profileName),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                        minHeight: 48,
                                      ),
                                      child: ActionChip(
                                        backgroundColor:
                                            AppColors.badgeBackground,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => HrMonitorView(
                                                deviceId: profile.macAddress,
                                                deviceName: profile.name.isEmpty
                                                    ? l10n.savedSensorFallbackName
                                                    : profile.name,
                                              ),
                                            ),
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
                ),

              // --- SCAN FOR NEW SENSOR CTA ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Consumer(
                      builder: (context, ref, _) {
                        return Semantics(
                          button: true,
                          label: l10n.scanForNewSensorButton,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const ExcludeSemantics(
                              child: Icon(
                                Icons.search,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                            ),
                            label: Text(
                              l10n.scanForNewSensorButton,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HrScannerView(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // --- WORKOUT HISTORY PLACEHOLDER ---
              SliverToBoxAdapter(
                child: _buildPlaceholderSection(
                  context,
                  title: l10n.workoutHistoryTitle,
                  icon: Icons.fitness_center,
                  description: l10n.workoutHistoryDescription,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkoutHistoryView(),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  /// Builds a tappable placeholder card for a feature section.
  Widget _buildPlaceholderSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      constraints: const BoxConstraints(minHeight: 48),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Semantics(
          button: true,
          label: title,
          hint: description,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.accentBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
