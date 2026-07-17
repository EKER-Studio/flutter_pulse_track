import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/services/heart_rate_repository.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/infrastructure/services/fbp_heart_rate_repository.dart';

part 'heart_rate_providers.g.dart';

/// Provides a HeartRateRepository instance scoped to a specific device configuration.
@riverpod
HeartRateRepository heartRateRepository(Ref ref, String deviceId) {
  return FbpHeartRateRepository(deviceId);
}

/// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
///
/// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
/// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
/// tears down native BLE notifications to preserve device battery.
@riverpod
Stream<HrMeasurement> heartRateMetrics(Ref ref, String deviceId) {
  final repository = ref.watch(heartRateRepositoryProvider(deviceId));
  return repository.heartRateStream;
}
