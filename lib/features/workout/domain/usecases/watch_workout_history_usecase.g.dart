// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_workout_history_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [WatchWorkoutHistoryUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.

@ProviderFor(watchWorkoutHistoryUseCase)
final watchWorkoutHistoryUseCaseProvider =
    WatchWorkoutHistoryUseCaseProvider._();

/// Riverpod provider that supplies a [WatchWorkoutHistoryUseCase] wired to
/// the concrete [WorkoutPersistenceRepository] implementation.

final class WatchWorkoutHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          WatchWorkoutHistoryUseCase,
          WatchWorkoutHistoryUseCase,
          WatchWorkoutHistoryUseCase
        >
    with $Provider<WatchWorkoutHistoryUseCase> {
  /// Riverpod provider that supplies a [WatchWorkoutHistoryUseCase] wired to
  /// the concrete [WorkoutPersistenceRepository] implementation.
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
    r'b38929bec70b69ddb5706b5f5745925bfc6054e1';

/// Reactive stream of workout history for direct use in
/// `ref.watch(watchWorkoutHistoryProvider)` from views.

@ProviderFor(watchWorkoutHistoryStream)
final watchWorkoutHistoryStreamProvider = WatchWorkoutHistoryStreamProvider._();

/// Reactive stream of workout history for direct use in
/// `ref.watch(watchWorkoutHistoryProvider)` from views.

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
  /// Reactive stream of workout history for direct use in
  /// `ref.watch(watchWorkoutHistoryProvider)` from views.
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
