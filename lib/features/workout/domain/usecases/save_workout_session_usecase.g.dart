// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_workout_session_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [SaveWorkoutSessionUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].

@ProviderFor(saveWorkoutSessionUseCase)
final saveWorkoutSessionUseCaseProvider = SaveWorkoutSessionUseCaseProvider._();

/// Riverpod provider that supplies a [SaveWorkoutSessionUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].

final class SaveWorkoutSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SaveWorkoutSessionUseCase,
          SaveWorkoutSessionUseCase,
          SaveWorkoutSessionUseCase
        >
    with $Provider<SaveWorkoutSessionUseCase> {
  /// Riverpod provider that supplies a [SaveWorkoutSessionUseCase] wired to the
  /// abstract [WorkoutPersistenceRepository] contract using [ref].
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
