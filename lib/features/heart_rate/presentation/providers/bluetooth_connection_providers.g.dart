// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the concrete implementation of the connection service.

@ProviderFor(bluetoothConnectionService)
final bluetoothConnectionServiceProvider =
    BluetoothConnectionServiceProvider._();

/// Provides the concrete implementation of the connection service.

final class BluetoothConnectionServiceProvider
    extends
        $FunctionalProvider<
          BluetoothConnectionService,
          BluetoothConnectionService,
          BluetoothConnectionService
        >
    with $Provider<BluetoothConnectionService> {
  /// Provides the concrete implementation of the connection service.
  BluetoothConnectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothConnectionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothConnectionServiceHash();

  @$internal
  @override
  $ProviderElement<BluetoothConnectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BluetoothConnectionService create(Ref ref) {
    return bluetoothConnectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothConnectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothConnectionService>(value),
    );
  }
}

String _$bluetoothConnectionServiceHash() =>
    r'83177dcae8d239f6f175faf06e09a62998457fed';

/// Controller responsible for managing connection state and executing lifecycle intents.
///
/// Replaces the legacy void controller with a robust AsyncValue wrapper driving the UI.

@ProviderFor(BluetoothConnectionController)
final bluetoothConnectionControllerProvider =
    BluetoothConnectionControllerProvider._();

/// Controller responsible for managing connection state and executing lifecycle intents.
///
/// Replaces the legacy void controller with a robust AsyncValue wrapper driving the UI.
final class BluetoothConnectionControllerProvider
    extends
        $StreamNotifierProvider<
          BluetoothConnectionController,
          BleConnectionStatus
        > {
  /// Controller responsible for managing connection state and executing lifecycle intents.
  ///
  /// Replaces the legacy void controller with a robust AsyncValue wrapper driving the UI.
  BluetoothConnectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothConnectionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothConnectionControllerHash();

  @$internal
  @override
  BluetoothConnectionController create() => BluetoothConnectionController();
}

String _$bluetoothConnectionControllerHash() =>
    r'75a491b3300ee610359e8a6e6dcadf91daa0e124';

/// Controller responsible for managing connection state and executing lifecycle intents.
///
/// Replaces the legacy void controller with a robust AsyncValue wrapper driving the UI.

abstract class _$BluetoothConnectionController
    extends $StreamNotifier<BleConnectionStatus> {
  Stream<BleConnectionStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BleConnectionStatus>, BleConnectionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BleConnectionStatus>, BleConnectionStatus>,
              AsyncValue<BleConnectionStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
