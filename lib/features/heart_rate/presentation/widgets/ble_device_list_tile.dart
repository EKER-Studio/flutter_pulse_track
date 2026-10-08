import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Interactive list tile representing a discovered BLE heart rate device.
///
/// Shows device name, MAC/UUID identifier, RSSI signal strength indicator,
/// and handles tap events to navigate to telemetry monitoring.
class BleDeviceListTile extends StatelessWidget {
  /// The discovered BLE device metadata.
  final BleDevice device;

  /// Callback triggered when the tile is tapped.
  final VoidCallback onTap;

  const BleDeviceListTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deviceName = device.name.isEmpty ? l10n.unknown_device : device.name;

    return Semantics(
      label: deviceName,
      hint: l10n.deviceListTileHint(device.id, device.rssi),
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
        title: Text(
          deviceName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          device.id,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
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
        onTap: onTap,
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -65) return AppColors.accentGreen;
    if (rssi >= -85) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  IconData _getRssiIcon(int rssi) {
    if (rssi >= -65) return Icons.signal_cellular_alt;
    if (rssi >= -85) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }
}
