// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_partial_workout_session_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.

@ProviderFor(savePartialWorkoutSessionUseCase)
final savePartialWorkoutSessionUseCaseProvider =
    SavePartialWorkoutSessionUseCaseProvider._();

/// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.

final class SavePartialWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase,
          SavePartialWorkoutSessionUseCase
        >
    with $Provider<SavePartialWorkoutSessionUseCase> {
  /// Riverpod provider that supplies a [SavePartialWorkoutSessionUseCase] wired to
  /// the concrete [WorkoutPersistenceRepository] implementation.
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
    r'8ac0ab1a072232a99e67a50218c2fb836734dc7a';
