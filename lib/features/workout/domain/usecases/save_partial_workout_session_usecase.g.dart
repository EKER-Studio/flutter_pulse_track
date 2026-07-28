// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_partial_workout_session_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].

@ProviderFor(savePartialWorkoutSessionUseCase)
final savePartialWorkoutSessionUseCaseProvider =
    SavePartialWorkoutSessionUseCaseProvider._();

/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the abstract [WorkoutPersistenceRepository] contract using [ref].

final class SavePartialWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase
        >
    with $Provider<SavePartialWorkoutSessionUseCase> {
  /// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
  /// the abstract [WorkoutPersistenceRepository] contract using [ref].
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
