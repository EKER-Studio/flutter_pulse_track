import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';
import 'package:pulse_track/core/integrations/biometrics/biometric_service.dart';

export 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart'
    show ForegroundServiceManager;
export 'package:pulse_track/core/infrastructure/services/analytics_service.dart'
    show AnalyticsService, analyticsServiceProvider;
export 'package:pulse_track/core/integrations/biometrics/biometric_service.dart'
    show BiometricAuthResult, BiometricService;

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
ForegroundServiceManager foregroundServiceManager(Ref ref) {
  return ForegroundServiceManager();
}

/// Provides the singleton [BiometricService] instance.
@Riverpod(keepAlive: true)
BiometricService biometricService(Ref ref) {
  return BiometricService.instance;
}
