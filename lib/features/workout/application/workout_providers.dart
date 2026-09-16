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

/// Riverpod provider delivering the concrete Isar-backed [WorkoutPersistenceRepository].
@riverpod
WorkoutPersistenceRepository workoutPersistenceRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  return infra.WorkoutPersistenceRepository(isar);
}

/// Riverpod provider that supplies a [SaveWorkoutSessionUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
SaveWorkoutSessionUseCase saveWorkoutSessionUseCase(Ref ref) {
  return SaveWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
SavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase(Ref ref) {
  return SavePartialWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [SaveDeviceProfileUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
SaveDeviceProfileUseCase saveDeviceProfileUseCase(Ref ref) {
  return SaveDeviceProfileUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [DeleteWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
DeleteWorkoutSessionUseCase deleteWorkoutSessionUseCase(Ref ref) {
  return DeleteWorkoutSessionUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [WatchWorkoutHistoryUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
WatchWorkoutHistoryUseCase watchWorkoutHistoryUseCase(Ref ref) {
  return WatchWorkoutHistoryUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [WatchSavedDeviceProfilesUseCase] wired
/// to the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
WatchSavedDeviceProfilesUseCase watchSavedDeviceProfilesUseCase(Ref ref) {
  return WatchSavedDeviceProfilesUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Riverpod provider that supplies a [SanitizeCrashedSessionsUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].
@riverpod
SanitizeCrashedSessionsUseCase sanitizeCrashedSessionsUseCase(Ref ref) {
  return SanitizeCrashedSessionsUseCase(
    ref.watch(workoutPersistenceRepositoryProvider),
  );
}

/// Reactive stream of workout history for direct use in
/// `ref.watch(watchWorkoutHistoryStreamProvider)` from views using [ref].
@riverpod
Stream<List<WorkoutSession>> watchWorkoutHistoryStream(Ref ref) {
  return ref.watch(watchWorkoutHistoryUseCaseProvider).call();
}

/// Reactive stream of saved device profiles for direct use in
/// `ref.watch(watchSavedDeviceProfilesStreamProvider)` from views using [ref].
@riverpod
Stream<List<DeviceProfile>> watchSavedDeviceProfilesStream(Ref ref) {
  return ref.watch(watchSavedDeviceProfilesUseCaseProvider).call();
}

/// Riverpod provider supplying a singleton [WorkoutExportShareService].
@riverpod
WorkoutExportShareService workoutExportShareService(Ref ref) {
  return WorkoutExportShareService();
}
