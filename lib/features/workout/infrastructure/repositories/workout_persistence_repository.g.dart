// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_persistence_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider delivering the [WorkoutPersistenceRepository] instance using [ref].

@ProviderFor(workoutPersistenceRepository)
final workoutPersistenceRepositoryProvider =
    WorkoutPersistenceRepositoryProvider._();

/// Riverpod provider delivering the [WorkoutPersistenceRepository] instance using [ref].

final class WorkoutPersistenceRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository,
          WorkoutPersistenceRepository
        >
    with $Provider<WorkoutPersistenceRepository> {
  /// Riverpod provider delivering the [WorkoutPersistenceRepository] instance using [ref].
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
    r'6442ff9bd201913bc1acd5411566581c5f8eac70';
