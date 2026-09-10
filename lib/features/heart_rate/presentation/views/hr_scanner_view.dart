import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Main entry point for discovering BLE heart rate sensors.
///
/// Implements an exhaustive state machine UI reacting to [BleScannerState]
/// emitted by the [bleScannerNotifierProvider].
class HrScannerView extends ConsumerWidget {
  /// Creates an [HrScannerView] instance.
  const HrScannerView({super.key});

  /// Builds the BLE scanner view using [context] and [ref].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bleScannerProvider);
    final notifier = ref.read(bleScannerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).scanner_title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),

        /// AppBar actions containing the filter toggle button with explicit hit‑area and semantics.
        actions: [
          // Filter toggle button only relevant when scanning or empty
          if (state is ScanningScannerState || state is EmptyScannerState)
            Semantics(
              /** Semantic label for the filter toggle button, used by screen readers. */
              label: AppLocalizations.of(context).toggle_filter_tooltip,
              button: true,
              toggled: _isFilterActive(notifier),
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  _isFilterActive(notifier)
                      ? Icons.filter_list
                      : Icons.filter_list_off,
                  color: _isFilterActive(notifier)
                      ? AppColors.accentBlue
                      : AppColors.textSecondary,
                ),
                /** Tooltip text for the filter toggle button, also read by accessibility services. */
                tooltip: AppLocalizations.of(context).toggle_filter_tooltip,
                onPressed: () => notifier.toggleFilters(),
              ),
            ),
        ],
      ),
      // Exhaustive switch expression enforcing UI coverage for all sealed states
      body: switch (state) {
        IdleScannerState() => _buildIdleState(context, notifier),
        AdapterOffScannerState() => _buildAdapterOffState(context),
        EmptyScannerState() => _buildEmptyState(context, notifier),
        ScanningScannerState(:final devices) => _buildScanningState(
          context,
          notifier,
          devices,
        ),
        FailureScannerState(:final message) => _buildFailureState(
          context,
          message,
          notifier,
        ),
      },
    );
  }

  /// Returns true if any device type filter is currently active.
  bool _isFilterActive(BleScannerNotifier notifier) {
    return notifier.filtersEnabled;
  }

  /// Builds the idle state UI displayed when no scan is active and no devices have been found.
  Widget _buildIdleState(BuildContext context, BleScannerNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Icon indicating scanning state with semantic label for accessibility.
          Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: AppColors.textSecondary,
            /** Semantic label for the Bluetooth searching icon, describing its purpose. */
            semanticLabel: AppLocalizations.of(context)
                .bluetooth_searching_label,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).ready_to_scan,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).start_scan_description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            /** Semantic label for the Scan button, announcing its action to screen readers. */
            label: AppLocalizations.of(context).scan_button_semantic_label,
            button: true,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const ExcludeSemantics(
                child: Icon(Icons.search, color: AppColors.textPrimary),
              ),
              label: Text(
                AppLocalizations.of(context).scan_button_label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => notifier.startScan(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI displayed when the Bluetooth adapter is off.
  Widget _buildAdapterOffState(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.accentRed.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Icon shown when Bluetooth is disabled, includes semantic label for screen readers.
            Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: AppColors.accentRed,
              /** Semantic label for the Bluetooth disabled icon, indicating Bluetooth is off. */
              semanticLabel: AppLocalizations.of(context)
                  .bluetooth_disabled_label,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).bluetooth_required,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).bluetooth_off_description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state UI displayed when scanning has completed but no devices were found.
  Widget _buildEmptyState(BuildContext context, BleScannerNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.device_unknown,
              size: 80,
              color: AppColors.accentOrange,
              /** Semantic label for the unknown device icon, indicating the device is not recognized. */
              semanticLabel: AppLocalizations.of(context).device_unknown_label,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).empty_state_title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).empty_state_bullets,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 32),

            /// Semantics wrapper for the retry scan button, providing an accessibility label.
            Semantics(
              /** Semantic label for the Retry Scan button, used by assistive technologies. */
              label: AppLocalizations.of(context).retry_scan_semantic_label,
              button: true,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const ExcludeSemantics(
                  child: Icon(Icons.refresh, color: AppColors.textPrimary),
                ),
                label: Text(
                  AppLocalizations.of(context).retry_scan_label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => notifier.startScan(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the failure state UI displayed when the scan could not be started.
  Widget _buildFailureState(
    BuildContext context,
    String message,
    BleScannerNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentRed.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.accentRed,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).scan_failed_title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: AppLocalizations.of(context).scan_button_semantic_label,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => notifier.startScan(),
                  child: Text(
                    AppLocalizations.of(context).scan_button_label,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the scanning state UI with an animated indicator and the list of discovered devices.
  ///
  /// Returned directly as `Scaffold.body` — must NOT be wrapped in `Expanded`,
  /// Placeholderes a `Flex` (Row/Column) ancestor, which
  /// `Scaffold.body` is not. `Center`/`ListView` already fill the available
  /// space on their own here.
  Widget _buildScanningState(
    BuildContext context,
    BleScannerNotifier notifier,
    List<BleDevice> devices,
  ) {
    return devices.isEmpty
        ? Center(
            child: Text(
              AppLocalizations.of(context).searching_sensors,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        : ListView.separated(
            itemCount: devices.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.borderSubtle, height: 1),
            itemBuilder: (context, index) {
              final device = devices[index];
              final deviceName = device.name.isEmpty
                  ? AppLocalizations.of(context).unknown_device
                  : device.name;
              return
              /// Semantics wrapper for each device list tile, combining device name and RSSI for accessibility.
              Semantics(
                label: deviceName,
                hint: AppLocalizations.of(context)
                    .deviceListTileHint(device.id, device.rssi),
                button: true,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bluetooth,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  title: Flexible(
                    child: Text(
                      deviceName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Flexible(
                    child: Text(
                      device.id,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: ExcludeSemantics(
                    child: SizedBox(
                      width: 56,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRssiIcon(device.rssi),
                            color: _getRssiColor(device.rssi),
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${device.rssi} dBm',
                            style: TextStyle(
                              color: _getRssiColor(device.rssi),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    await notifier.stopScan();
                    if (!context.mounted) return;
                    final targetName = device.name.isEmpty
                        ? AppLocalizations.of(context).unknown_device
                        : device.name;
                    context.push(
                      '/monitor?deviceId=${Uri.encodeComponent(device.id)}&deviceName=${Uri.encodeComponent(targetName)}',
                    );
                  },
                ),
              );
            },
          );
  }

  /// Returns a color representing signal strength for the given RSSI value.
  Color _getRssiColor(int rssi) {
    if (rssi >= -65) return AppColors.accentGreen;
    if (rssi >= -85) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  /// Returns an icon representing signal strength for the given RSSI value.
  IconData _getRssiIcon(int rssi) {
    if (rssi >= -65) return Icons.signal_cellular_alt;
    if (rssi >= -85) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }
}
