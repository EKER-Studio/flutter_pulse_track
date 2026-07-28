// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_device_profile_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that supplies a [SaveDeviceProfileUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].

@ProviderFor(saveDeviceProfileUseCase)
final saveDeviceProfileUseCaseProvider = SaveDeviceProfileUseCaseProvider._();

/// Riverpod provider that supplies a [SaveDeviceProfileUseCase] wired to the
/// abstract [WorkoutPersistenceRepository] contract using [ref].

final class SaveDeviceProfileUseCaseProvider
    extends
        $FunctionalProvider<
          SaveDeviceProfileUseCase,
          SaveDeviceProfileUseCase,
          SaveDeviceProfileUseCase
        >
    with $Provider<SaveDeviceProfileUseCase> {
  /// Riverpod provider that supplies a [SaveDeviceProfileUseCase] wired to the
  /// abstract [WorkoutPersistenceRepository] contract using [ref].
  SaveDeviceProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDeviceProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDeviceProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveDeviceProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDeviceProfileUseCase create(Ref ref) {
    return saveDeviceProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDeviceProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDeviceProfileUseCase>(value),
    );
  }
}

String _$saveDeviceProfileUseCaseHash() =>
    r'a0abde423911ad91af1584ddf75157a73d911550';
