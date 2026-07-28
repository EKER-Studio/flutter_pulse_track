// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_export_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider supplying a singleton instance of [WorkoutExportService].

@ProviderFor(workoutExportService)
final workoutExportServiceProvider = WorkoutExportServiceProvider._();

/// Riverpod provider supplying a singleton instance of [WorkoutExportService].

final class WorkoutExportServiceProvider
    extends
        $FunctionalProvider<
          WorkoutExportService,
          WorkoutExportService,
          WorkoutExportService
        >
    with $Provider<WorkoutExportService> {
  /// Riverpod provider supplying a singleton instance of [WorkoutExportService].
  WorkoutExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutExportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutExportServiceHash();

  @$internal
  @override
  $ProviderElement<WorkoutExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutExportService create(Ref ref) {
    return workoutExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutExportService>(value),
    );
  }
}

String _$workoutExportServiceHash() =>
    r'508e3de9cf8c12529f07c55bd61c269656f3533e';
