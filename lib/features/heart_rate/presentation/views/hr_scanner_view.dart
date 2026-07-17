import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_device.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/presentation/views/hr_monitor_view.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filter toggle button only relevant when scanning or empty
          if (state is ScanningScannerState || state is EmptyScannerState)
            IconButton(
              icon: Icon(
                _isFilterActive(notifier)
                    ? Icons.filter_list
                    : Icons.filter_list_off,
                color: _isFilterActive(notifier)
                    ? Colors.blueAccent
                    : Colors.grey,
              ),
              tooltip: 'Toggle Names & Nearby Filter',
              onPressed: () => notifier.toggleFilters(),
            ),
        ],
      ),
      // Exhaustive switch expression enforcing UI coverage for all sealed states
      body: switch (state) {
        IdleScannerState() => _buildIdleState(notifier),
        AdapterOffScannerState() => _buildAdapterOffState(),
        EmptyScannerState() => _buildEmptyState(notifier),
        ScanningScannerState(:final devices) => _buildScanningState(
          context,
          notifier,
          devices,
        ),
        FailureScannerState(:final message) => _buildFailureState(
          message,
          notifier,
        ),
      },
    );
  }

  bool _isFilterActive(BleScannerNotifier notifier) {
    return notifier.filtersEnabled;
  }

  Widget _buildIdleState(BleScannerNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Ready to scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap Scan to begin searching for sensors.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text(
              'Scan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => notifier.startScan(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdapterOffState() {
    return Container(
      width: double.infinity,
      color: Colors.redAccent.withValues(alpha: 0.05),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 80, color: Colors.redAccent),
            SizedBox(height: 24),
            Text(
              'Bluetooth Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Bluetooth adapter is powered off or unauthorized. Please enable Bluetooth and grant local infrastructure permissions to scan for sensors.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BleScannerNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.device_unknown,
              size: 80,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              "CAN'T SEE YOUR DEVICE?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Ensure the sensor is powered on.\n'
              '• Check the sensor battery.\n'
              '• Move closer to the device.\n'
              '• Try disabling the scan filters.',
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry Scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => notifier.startScan(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureState(String message, BleScannerNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => notifier.startScan(),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningState(
    BuildContext context,
    BleScannerNotifier notifier,
    List<BleDevice> devices,
  ) {
    return devices.isEmpty
        ? const Expanded(
            child: Center(
              child: Text(
                'Searching for active sensors...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        : Expanded(
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Flexible(
                    child: Text(
                      device.name.isEmpty ? 'Unknown Device' : device.name,
                      style: const TextStyle(
                        color: Colors.white,
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
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: SizedBox(
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
                  onTap: () {
                    notifier.stopScan();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HrMonitorView(
                          deviceId: device.id,
                          deviceName: device.name.isEmpty
                              ? 'Unknown Device'
                              : device.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -65) return Colors.greenAccent;
    if (rssi >= -85) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  IconData _getRssiIcon(int rssi) {
    if (rssi >= -65) return Icons.signal_cellular_alt;
    if (rssi >= -85) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }
}
