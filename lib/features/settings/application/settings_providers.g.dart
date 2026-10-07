// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [UserSettingsRepository] instance globally.
///
/// Lives in the application layer so presentation depends on the domain
/// contract, not on the Isar-backed implementation file.

@ProviderFor(userSettingsRepository)
final userSettingsRepositoryProvider = UserSettingsRepositoryProvider._();

/// Provides the active [UserSettingsRepository] instance globally.
///
/// Lives in the application layer so presentation depends on the domain
/// contract, not on the Isar-backed implementation file.

final class UserSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          UserSettingsRepository,
          UserSettingsRepository,
          UserSettingsRepository
        >
    with $Provider<UserSettingsRepository> {
  /// Provides the active [UserSettingsRepository] instance globally.
  ///
  /// Lives in the application layer so presentation depends on the domain
  /// contract, not on the Isar-backed implementation file.
  UserSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserSettingsRepository create(Ref ref) {
    return userSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettingsRepository>(value),
    );
  }
}

String _$userSettingsRepositoryHash() =>
    r'5bef139bc768ce292fc1fbc3ac3b2f6729b072f9';

/// Provides the [CsvWorkoutImportService] for CSV import from presentation.
///
/// Lives here (not in `infrastructure/services/csv_workout_import_service.dart`)
/// so presentation depends on the application layer, never on infrastructure.

@ProviderFor(csvWorkoutImportService)
final csvWorkoutImportServiceProvider = CsvWorkoutImportServiceProvider._();

/// Provides the [CsvWorkoutImportService] for CSV import from presentation.
///
/// Lives here (not in `infrastructure/services/csv_workout_import_service.dart`)
/// so presentation depends on the application layer, never on infrastructure.

final class CsvWorkoutImportServiceProvider
    extends
        $FunctionalProvider<
          CsvWorkoutImportService,
          CsvWorkoutImportService,
          CsvWorkoutImportService
        >
    with $Provider<CsvWorkoutImportService> {
  /// Provides the [CsvWorkoutImportService] for CSV import from presentation.
  ///
  /// Lives here (not in `infrastructure/services/csv_workout_import_service.dart`)
  /// so presentation depends on the application layer, never on infrastructure.
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
