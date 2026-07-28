// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_persistence_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider supplying the [WorkoutPersistenceRepository] domain contract.
///
/// Throws [UnimplementedError] by default. Must be overridden in [ProviderScope]
/// with a concrete infrastructure implementation.

@ProviderFor(workoutPersistenceRepository)
final workoutPersistenceRepositoryProvider =
    WorkoutPersistenceRepositoryProvider._();

/// Provider supplying the [WorkoutPersistenceRepository] domain contract.
///
/// Throws [UnimplementedError] by default. Must be overridden in [ProviderScope]
/// with a concrete infrastructure implementation.

final class WorkoutPersistenceRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository
        >
    with $Provider<WorkoutPersistenceRepository> {
  /// Provider supplying the [WorkoutPersistenceRepository] domain contract.
  ///
  /// Throws [UnimplementedError] by default. Must be overridden in [ProviderScope]
  /// with a concrete infrastructure implementation.
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
    r'06fa20a672ee1ef68a18bc147565e11b95598cf1';
