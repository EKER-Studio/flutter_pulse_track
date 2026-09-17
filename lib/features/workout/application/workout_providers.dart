import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/storage/isar_provider.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/domain/repositories/workout_persistence_repository.dart';
import 'package:pulse_track/features/workout/domain/usecases/delete_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/sanitize_crashed_sessions_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_saved_device_profiles_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/watch_workout_history_usecase.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart'
    as infra;
import 'package:pulse_track/features/workout/infrastructure/services/workout_export_share_service.dart';

export 'package:pulse_track/features/workout/infrastructure/services/workout_export_share_service.dart'
    show WorkoutExportShareService;

part 'workout_providers.g.dart';

@riverpod
WorkoutPersistenceRepository workoutPersistenceRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return infra.WorkoutPersistenceRepository(isar);
}

@riverpod
SaveWorkoutSessionUseCase saveWorkoutSessionUseCase(Ref ref) {
  return SaveWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
SavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase(Ref ref) {
  return SavePartialWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
SaveDeviceProfileUseCase saveDeviceProfileUseCase(Ref ref) {
  return SaveDeviceProfileUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
DeleteWorkoutSessionUseCase deleteWorkoutSessionUseCase(Ref ref) {
  return DeleteWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
WatchWorkoutHistoryUseCase watchWorkoutHistoryUseCase(Ref ref) {
  return WatchWorkoutHistoryUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
WatchSavedDeviceProfilesUseCase watchSavedDeviceProfilesUseCase(Ref ref) {
  return WatchSavedDeviceProfilesUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
SanitizeCrashedSessionsUseCase sanitizeCrashedSessionsUseCase(Ref ref) {
  return SanitizeCrashedSessionsUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

@riverpod
Stream<List<WorkoutSession>> watchWorkoutHistoryStream(Ref ref) {
  return ref.watch(watchWorkoutHistoryUseCaseProvider).call();
}

@riverpod
Stream<List<DeviceProfile>> watchSavedDeviceProfilesStream(Ref ref) {
  return ref.watch(watchSavedDeviceProfilesUseCaseProvider).call();
}

@riverpod
WorkoutExportShareService workoutExportShareService(Ref ref) {
  return WorkoutExportShareService();
}
