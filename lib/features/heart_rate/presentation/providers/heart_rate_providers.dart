import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/hr_measurement.dart';
import '../../domain/services/heart_rate_repository.dart';
import '../../infrastructure/services/fbp_heart_rate_repository.dart';

part 'heart_rate_providers.g.dart';

/// Provides a HeartRateRepository instance scoped to a specific device configuration.
@riverpod
HeartRateRepository heartRateRepository(Ref ref, String deviceId) {
  return FbpHeartRateRepository(deviceId);
}

/// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
@riverpod
Stream<HrMeasurement> heartRateMetrics(Ref ref, String deviceId) {
  final repository = ref.watch(heartRateRepositoryProvider(deviceId));
  return repository.heartRateStream;
}