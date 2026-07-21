// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_saved_device_profiles_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [WatchSavedDeviceProfilesUseCase] wired
/// to the concrete [WorkoutPersistenceRepository] implementation.

@ProviderFor(watchSavedDeviceProfilesUseCase)
final watchSavedDeviceProfilesUseCaseProvider =
    WatchSavedDeviceProfilesUseCaseProvider._();

/// Riverpod provider that supplies a [WatchSavedDeviceProfilesUseCase] wired
/// to the concrete [WorkoutPersistenceRepository] implementation.

final class WatchSavedDeviceProfilesUseCaseProvider
    extends
        $FunctionalProvider<
          WatchSavedDeviceProfilesUseCase,
          WatchSavedDeviceProfilesUseCase,
          WatchSavedDeviceProfilesUseCase
        >
    with $Provider<WatchSavedDeviceProfilesUseCase> {
  /// Riverpod provider that supplies a [WatchSavedDeviceProfilesUseCase] wired
  /// to the concrete [WorkoutPersistenceRepository] implementation.
  WatchSavedDeviceProfilesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavedDeviceProfilesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavedDeviceProfilesUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchSavedDeviceProfilesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchSavedDeviceProfilesUseCase create(Ref ref) {
    return watchSavedDeviceProfilesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchSavedDeviceProfilesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchSavedDeviceProfilesUseCase>(
        value,
      ),
    );
  }
}

String _$watchSavedDeviceProfilesUseCaseHash() =>
    r'fefd0be05810beb9bccdd13437cd6897b3e31be1';

/// Reactive stream of saved device profiles for direct use in
/// `ref.watch(watchSavedDeviceProfilesProvider)` from views.

@ProviderFor(watchSavedDeviceProfilesStream)
final watchSavedDeviceProfilesStreamProvider =
    WatchSavedDeviceProfilesStreamProvider._();

/// Reactive stream of saved device profiles for direct use in
/// `ref.watch(watchSavedDeviceProfilesProvider)` from views.

final class WatchSavedDeviceProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceProfile>>,
          List<DeviceProfile>,
          Stream<List<DeviceProfile>>
        >
    with
        $FutureModifier<List<DeviceProfile>>,
        $StreamProvider<List<DeviceProfile>> {
  /// Reactive stream of saved device profiles for direct use in
  /// `ref.watch(watchSavedDeviceProfilesProvider)` from views.
  WatchSavedDeviceProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSavedDeviceProfilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSavedDeviceProfilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<DeviceProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeviceProfile>> create(Ref ref) {
    return watchSavedDeviceProfilesStream(ref);
  }
}

String _$watchSavedDeviceProfilesStreamHash() =>
    r'2443548c5d0ebe22545fc41e8a9096900ea45cdc';
