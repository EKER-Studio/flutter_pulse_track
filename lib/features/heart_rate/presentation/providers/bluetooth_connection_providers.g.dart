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

/// Exposes a reactive stream of the current BLE connection status to the UI.

@ProviderFor(bleConnectionStatus)
final bleConnectionStatusProvider = BleConnectionStatusProvider._();

/// Exposes a reactive stream of the current BLE connection status to the UI.

final class BleConnectionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<BleConnectionStatus>,
          BleConnectionStatus,
          Stream<BleConnectionStatus>
        >
    with
        $FutureModifier<BleConnectionStatus>,
        $StreamProvider<BleConnectionStatus> {
  /// Exposes a reactive stream of the current BLE connection status to the UI.
  BleConnectionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleConnectionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleConnectionStatusHash();

  @$internal
  @override
  $StreamProviderElement<BleConnectionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BleConnectionStatus> create(Ref ref) {
    return bleConnectionStatus(ref);
  }
}

String _$bleConnectionStatusHash() =>
    r'd1f239e02bcbf1d9ccdac74073ef2573ef2fcd0a';

/// Controller responsible for executing connect and disconnect intents.

@ProviderFor(BluetoothConnectionController)
final bluetoothConnectionControllerProvider =
    BluetoothConnectionControllerProvider._();

/// Controller responsible for executing connect and disconnect intents.
final class BluetoothConnectionControllerProvider
    extends $NotifierProvider<BluetoothConnectionController, void> {
  /// Controller responsible for executing connect and disconnect intents.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bluetoothConnectionControllerHash() =>
    r'87b92f75880a91c4267392df2c3ed5a9be3726e5';

/// Controller responsible for executing connect and disconnect intents.

abstract class _$BluetoothConnectionController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
