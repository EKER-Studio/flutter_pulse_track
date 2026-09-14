import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/core/integrations/health/health_sync_coordinator.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';

part 'health_providers.g.dart';

/// Riverpod provider supplying the singleton [HealthService] contract using [ref].
@Riverpod(keepAlive: true)
HealthService healthService(Ref ref) {
  return NativeHealthService.instance;
}

/// Riverpod provider supplying the [HealthSyncCoordinator] wired to [healthService] and repository using [ref].
@Riverpod(keepAlive: true)
HealthSyncCoordinator healthSyncCoordinator(Ref ref) {
  return HealthSyncCoordinator(
    healthService: ref.watch(healthServiceProvider),
    repository: ref.watch(workoutPersistenceRepositoryProvider),
  );
}
