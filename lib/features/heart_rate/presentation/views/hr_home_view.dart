import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/infrastructure/storage/isar_provider.dart';
import '../../../workout/infrastructure/models/device_profile_dto.dart';
import 'hr_monitor_view.dart';
import 'hr_scanner_view.dart';
import 'workout_history_view.dart';

/// Central dashboard hub for the heart rate monitoring application.
///
/// Displays a reactive list of saved sensor profiles from the local Isar
/// database for instant direct-connect, alongside navigation placeholders
/// for future features (Workout History, Build in Public Guide).
class HrHomeView extends ConsumerWidget {
  const HrHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'HR Companion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<DeviceProfileDto>>(
        stream: isar
            .deviceProfileDtos
            .where()
            .sortByLastConnectedAtDesc()
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          final savedProfiles = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // --- SAVED SENSORS SECTION ---
              if (savedProfiles.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      border: Border(
                        bottom: BorderSide(color: Colors.white10, width: 1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bluetooth_connected,
                                  color: Colors.blueAccent,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Saved Sensors (Direct Connect)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 44,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              itemCount: savedProfiles.length,
                              itemBuilder: (context, index) {
                                final profile = savedProfiles[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: ActionChip(
                                    backgroundColor: const Color(0xFF2A2A2A),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    avatar: const Icon(
                                      Icons.bluetooth_connected,
                                      color: Colors.greenAccent,
                                      size: 14,
                                    ),
                                    label: Text(
                                      profile.name.isEmpty
                                          ? 'Unknown Sensor'
                                          : profile.name,
                                      style: const TextStyle(
                                        color: Colors.white,
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
                                                ? 'Saved Sensor'
                                                : profile.name,
                                          ),
                                        ),
                                      );
                                    },
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
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text(
                            'Scan for New Sensor',
                            style: TextStyle(
                              color: Colors.white,
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
                  title: 'Workout History',
                  icon: Icons.fitness_center,
                  description: 'View past heart rate sessions and analytics.',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkoutHistoryView(),
                      ),
                    );
                  },
                ),
              ),

              // --- BUILD IN PUBLIC GUIDE PLACEHOLDER ---
              SliverToBoxAdapter(
                child: _buildPlaceholderSection(
                  context,
                  title: 'Build in Public Guide',
                  icon: Icons.menu_book,
                  description: 'Learn how to share your journey and connect with the community.',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }

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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
