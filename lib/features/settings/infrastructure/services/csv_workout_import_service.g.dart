// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_workout_import_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(csvWorkoutImportService)
final csvWorkoutImportServiceProvider = CsvWorkoutImportServiceProvider._();

final class CsvWorkoutImportServiceProvider
    extends
        $FunctionalProvider<
          CsvWorkoutImportService,
          CsvWorkoutImportService,
          CsvWorkoutImportService
        >
    with $Provider<CsvWorkoutImportService> {
  CsvWorkoutImportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'csvWorkoutImportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$csvWorkoutImportServiceHash();

  @$internal
  @override
  $ProviderElement<CsvWorkoutImportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CsvWorkoutImportService create(Ref ref) {
    return csvWorkoutImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CsvWorkoutImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CsvWorkoutImportService>(value),
    );
  }
}

String _$csvWorkoutImportServiceHash() =>
    r'945dc0185fc9c8fbf3f23a8d42ecf9a442f0a009';
