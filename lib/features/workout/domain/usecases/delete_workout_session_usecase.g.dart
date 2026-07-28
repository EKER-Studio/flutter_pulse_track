// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_workout_session_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [DeleteWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].

@ProviderFor(deleteWorkoutSessionUseCase)
final deleteWorkoutSessionUseCaseProvider =
    DeleteWorkoutSessionUseCaseProvider._();

/// Riverpod provider that supplies a [DeleteWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].

final class DeleteWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteWorkoutSessionUseCase,
          DeleteWorkoutSessionUseCase,
          DeleteWorkoutSessionUseCase
        >
    with $Provider<DeleteWorkoutSessionUseCase> {
  /// Riverpod provider that supplies a [DeleteWorkoutSessionUseCase] wired to
  /// the abstract [WorkoutPersistenceRepository] contract using [ref].
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
