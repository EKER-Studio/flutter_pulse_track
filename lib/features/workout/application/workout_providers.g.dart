// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutPersistenceRepository)
final workoutPersistenceRepositoryProvider =
    WorkoutPersistenceRepositoryProvider._();

final class WorkoutPersistenceRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository
        >
    with $Provider<WorkoutPersistenceRepository> {
  WorkoutPersistenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutPersistenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutPersistenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkoutPersistenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutPersistenceRepository create(Ref ref) {
    return workoutPersistenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutPersistenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutPersistenceRepository>(value),
    );
  }
}

String _$workoutPersistenceRepositoryHash() =>
    r'3887105e243703c2ea1e2eff8b3e93d921679fc9';

@ProviderFor(saveWorkoutSessionUseCase)
final saveWorkoutSessionUseCaseProvider = SaveWorkoutSessionUseCaseProvider._();

final class SaveWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SaveWorkoutSessionUseCase,
          SaveWorkoutSessionUseCase,
          SaveWorkoutSessionUseCase
        >
    with $Provider<SaveWorkoutSessionUseCase> {
  SaveWorkoutSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveWorkoutSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveWorkoutSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveWorkoutSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveWorkoutSessionUseCase create(Ref ref) {
    return saveWorkoutSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveWorkoutSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveWorkoutSessionUseCase>(value),
    );
  }
}

String _$saveWorkoutSessionUseCaseHash() =>
    r'006b1f32747f457d9f6f0b45092ef136ebbecadb';

@ProviderFor(savePartialWorkoutSessionUseCase)
final savePartialWorkoutSessionUseCaseProvider =
    SavePartialWorkoutSessionUseCaseProvider._();

final class SavePartialWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase
        >
    with $Provider<SavePartialWorkoutSessionUseCase> {
  SavePartialWorkoutSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savePartialWorkoutSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savePartialWorkoutSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<SavePartialWorkoutSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavePartialWorkoutSessionUseCase create(Ref ref) {
    return savePartialWorkoutSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavePartialWorkoutSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavePartialWorkoutSessionUseCase>(
        value,
      ),
    );
  }
}

String _$savePartialWorkoutSessionUseCaseHash() =>
    r'4f1b83048ef80eeb782a9ef7d9b0c7b65cfcc019';

@ProviderFor(saveDeviceProfileUseCase)
final saveDeviceProfileUseCaseProvider = SaveDeviceProfileUseCaseProvider._();

final class SaveDeviceProfileUseCaseProvider
    extends
        $FunctionalProvider<
          SaveDeviceProfileUseCase,
          SaveDeviceProfileUseCase,
          SaveDeviceProfileUseCase
        >
    with $Provider<SaveDeviceProfileUseCase> {
  SaveDeviceProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDeviceProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDeviceProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveDeviceProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDeviceProfileUseCase create(Ref ref) {
    return saveDeviceProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDeviceProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDeviceProfileUseCase>(value),
    );
  }
}

String _$saveDeviceProfileUseCaseHash() =>
    r'a0abde423911ad91af1584ddf75157a73d911550';

@ProviderFor(deleteWorkoutSessionUseCase)
final deleteWorkoutSessionUseCaseProvider =
    DeleteWorkoutSessionUseCaseProvider._();

final class DeleteWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteWorkoutSessionUseCase,
          DeleteWorkoutSessionUseCase,
          DeleteWorkoutSessionUseCase
        >
    with $Provider<DeleteWorkoutSessionUseCase> {
  DeleteWorkoutSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteWorkoutSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteWorkoutSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteWorkoutSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteWorkoutSessionUseCase create(Ref ref) {
    return deleteWorkoutSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteWorkoutSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteWorkoutSessionUseCase>(value),
    );
  }
}

String _$deleteWorkoutSessionUseCaseHash() =>
    r'4957744a77072749c328e70969cc5444285713fb';

@ProviderFor(watchWorkoutHistoryUseCase)
final watchWorkoutHistoryUseCaseProvider =
    WatchWorkoutHistoryUseCaseProvider._();

final class WatchWorkoutHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          WatchWorkoutHistoryUseCase,
          WatchWorkoutHistoryUseCase,
          WatchWorkoutHistoryUseCase
        >
    with $Provider<WatchWorkoutHistoryUseCase> {
  WatchWorkoutHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchWorkoutHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchWorkoutHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchWorkoutHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchWorkoutHistoryUseCase create(Ref ref) {
    return watchWorkoutHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchWorkoutHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchWorkoutHistoryUseCase>(value),
    );
  }
}

String _$watchWorkoutHistoryUseCaseHash() =>
    r'fffc58f3571edd7f052b8ce916e05eb48720effa';

@ProviderFor(watchSavedDeviceProfilesUseCase)
final watchSavedDeviceProfilesUseCaseProvider =
    WatchSavedDeviceProfilesUseCaseProvider._();

final class WatchSavedDeviceProfilesUseCaseProvider
    extends
        $FunctionalProvider<
          WatchSavedDeviceProfilesUseCase,
          WatchSavedDeviceProfilesUseCase,
          WatchSavedDeviceProfilesUseCase
        >
    with $Provider<WatchSavedDeviceProfilesUseCase> {
  WatchSavedDeviceProfilesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavedDeviceProfilesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavedDeviceProfilesUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchSavedDeviceProfilesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchSavedDeviceProfilesUseCase create(Ref ref) {
    return watchSavedDeviceProfilesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchSavedDeviceProfilesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchSavedDeviceProfilesUseCase>(
        value,
      ),
    );
  }
}

String _$watchSavedDeviceProfilesUseCaseHash() =>
    r'4307426cd984fe38f594ca4e8fe8b10e9322fc78';

@ProviderFor(sanitizeCrashedSessionsUseCase)
final sanitizeCrashedSessionsUseCaseProvider =
    SanitizeCrashedSessionsUseCaseProvider._();

final class SanitizeCrashedSessionsUseCaseProvider
    extends
        $FunctionalProvider<
          SanitizeCrashedSessionsUseCase,
          SanitizeCrashedSessionsUseCase,
          SanitizeCrashedSessionsUseCase
        >
    with $Provider<SanitizeCrashedSessionsUseCase> {
  SanitizeCrashedSessionsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sanitizeCrashedSessionsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sanitizeCrashedSessionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SanitizeCrashedSessionsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SanitizeCrashedSessionsUseCase create(Ref ref) {
    return sanitizeCrashedSessionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SanitizeCrashedSessionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SanitizeCrashedSessionsUseCase>(
        value,
      ),
    );
  }
}

String _$sanitizeCrashedSessionsUseCaseHash() =>
    r'46814a6cd96e24bde90ca467c35014a6a2092959';

@ProviderFor(watchWorkoutHistoryStream)
final watchWorkoutHistoryStreamProvider = WatchWorkoutHistoryStreamProvider._();

final class WatchWorkoutHistoryStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSession>>,
          List<WorkoutSession>,
          Stream<List<WorkoutSession>>
        >
    with
        $FutureModifier<List<WorkoutSession>>,
        $StreamProvider<List<WorkoutSession>> {
  WatchWorkoutHistoryStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchWorkoutHistoryStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchWorkoutHistoryStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkoutSession>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkoutSession>> create(Ref ref) {
    return watchWorkoutHistoryStream(ref);
  }
}

String _$watchWorkoutHistoryStreamHash() =>
    r'8acba6aee2573d844d671aab651796a80ea92491';

@ProviderFor(watchSavedDeviceProfilesStream)
final watchSavedDeviceProfilesStreamProvider =
    WatchSavedDeviceProfilesStreamProvider._();

final class WatchSavedDeviceProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceProfile>>,
          List<DeviceProfile>,
          Stream<List<DeviceProfile>>
        >
    with
        $FutureModifier<List<DeviceProfile>>,
        $StreamProvider<List<DeviceProfile>> {
  WatchSavedDeviceProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavedDeviceProfilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavedDeviceProfilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<DeviceProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeviceProfile>> create(Ref ref) {
    return watchSavedDeviceProfilesStream(ref);
  }
}

String _$watchSavedDeviceProfilesStreamHash() =>
    r'2443548c5d0ebe22545fc41e8a9096900ea45cdc';

@ProviderFor(workoutExportShareService)
final workoutExportShareServiceProvider = WorkoutExportShareServiceProvider._();

final class WorkoutExportShareServiceProvider
    extends
        $FunctionalProvider<
          WorkoutExportShareService,
          WorkoutExportShareService,
          WorkoutExportShareService
        >
    with $Provider<WorkoutExportShareService> {
  WorkoutExportShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutExportShareServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutExportShareServiceHash();

  @$internal
  @override
  $ProviderElement<WorkoutExportShareService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutExportShareService create(Ref ref) {
    return workoutExportShareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutExportShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutExportShareService>(value),
    );
  }
}

String _$workoutExportShareServiceHash() =>
    r'23164f93529916b87ea97b567b87d0d19ff11121';
