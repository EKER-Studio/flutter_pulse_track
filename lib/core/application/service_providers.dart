import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';

export 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart'
    show ForegroundServiceManager;
export 'package:pulse_track/core/infrastructure/services/analytics_service.dart'
    show AnalyticsService, analyticsServiceProvider;

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
ForegroundServiceManager foregroundServiceManager(Ref ref) {
  return ForegroundServiceManager();
}
