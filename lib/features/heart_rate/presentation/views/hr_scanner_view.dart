import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/failure_card.dart';
import 'package:pulse_track/core/presentation/widgets/status_state_view.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/ble_device_list_tile.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Main entry point for discovering BLE heart rate sensors.
///
/// Implements an exhaustive state machine UI reacting to [BleScannerState]
/// emitted by the [bleScannerNotifierProvider].
class HrScannerView extends ConsumerWidget {
  const HrScannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bleScannerProvider);
    final notifier = ref.read(bleScannerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.scanner_title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state is ScanningScannerState || state is EmptyScannerState)
            Semantics(
              label: l10n.toggle_filter_tooltip,
              button: true,
              toggled: notifier.filtersEnabled,
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  notifier.filtersEnabled
                      ? Icons.filter_list
                      : Icons.filter_list_off,
                  color: notifier.filtersEnabled
                      ? AppColors.accentBlue
                      : AppColors.textSecondary,
                ),
                tooltip: l10n.toggle_filter_tooltip,
                onPressed: () => notifier.toggleFilters(),
              ),
            ),
        ],
      ),
      body: switch (state) {
        IdleScannerState() => _buildIdleState(context, notifier, l10n),
        AdapterOffScannerState() => _buildAdapterOffState(context, l10n),
        EmptyScannerState() => _buildEmptyState(context, notifier, l10n),
        ScanningScannerState(:final devices) => _buildScanningState(
          context,
          notifier,
          devices,
          l10n,
        ),
        FailureScannerState(:final message) => _buildFailureState(
          context,
          message,
          notifier,
          l10n,
        ),
      },
    );
  }

  Widget _buildIdleState(
    BuildContext context,
    BleScannerNotifier notifier,
    AppLocalizations l10n,
  ) {
    return StatusStateView(
      icon: Icons.bluetooth_searching,
      iconSemanticLabel: l10n.bluetooth_searching_label,
      title: l10n.ready_to_scan,
      subtitle: l10n.start_scan_description,
      action: Semantics(
        label: l10n.scan_button_semantic_label,
        button: true,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const ExcludeSemantics(
            child: Icon(Icons.search, color: AppColors.textPrimary),
          ),
          label: Text(
            l10n.scan_button_label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => notifier.startScan(),
        ),
      ),
    );
  }

  Widget _buildAdapterOffState(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      color: AppColors.accentRed.withValues(alpha: 0.05),
      child: StatusStateView(
        icon: Icons.bluetooth_disabled,
        iconColor: AppColors.accentRed,
        iconSemanticLabel: l10n.bluetooth_disabled_label,
        title: l10n.bluetooth_required,
        subtitle: l10n.bluetooth_off_description,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    BleScannerNotifier notifier,
    AppLocalizations l10n,
  ) {
    return StatusStateView(
      icon: Icons.device_unknown,
      iconColor: AppColors.accentOrange,
      iconSemanticLabel: l10n.device_unknown_label,
      title: l10n.empty_state_title,
      customContent: Text(
        l10n.empty_state_bullets,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
      action: Semantics(
        label: l10n.retry_scan_semantic_label,
        button: true,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentOrange,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const ExcludeSemantics(
            child: Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
          label: Text(
            l10n.retry_scan_label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => notifier.retry(),
        ),
      ),
    );
  }

  Widget _buildFailureState(
    BuildContext context,
    String message,
    BleScannerNotifier notifier,
    AppLocalizations l10n,
  ) {
    return FailureCard(
      title: l10n.scan_failed_title,
      message: message,
      actions: [
        Semantics(
          button: true,
          label: l10n.scan_button_semantic_label,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => notifier.retry(),
            child: Text(
              l10n.scan_button_label,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningState(
    BuildContext context,
    BleScannerNotifier notifier,
    List<BleDevice> devices,
    AppLocalizations l10n,
  ) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          l10n.searching_sensors,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.borderSubtle, height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        return BleDeviceListTile(
          device: device,
          onTap: () async {
            await notifier.stopScan();
            if (!context.mounted) return;
            final targetName = device.name.isEmpty
                ? l10n.unknown_device
                : device.name;
            await context.push(
              '/monitor?deviceId=${Uri.encodeComponent(device.id)}&deviceName=${Uri.encodeComponent(targetName)}',
            );
          },
        );
      },
    );
  }
}
