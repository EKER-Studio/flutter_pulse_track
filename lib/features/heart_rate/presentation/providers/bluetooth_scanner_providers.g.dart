// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_scanner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the concrete implementation of the Bluetooth scanner service.

@ProviderFor(bluetoothScannerService)
final bluetoothScannerServiceProvider = BluetoothScannerServiceProvider._();

/// Provides the concrete implementation of the Bluetooth scanner service.

final class BluetoothScannerServiceProvider
    extends
        $FunctionalProvider<
          BluetoothScannerService,
          BluetoothScannerService,
          BluetoothScannerService
        >
    with $Provider<BluetoothScannerService> {
  /// Provides the concrete implementation of the Bluetooth scanner service.
  BluetoothScannerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothScannerServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothScannerServiceHash();

  @$internal
  @override
  $ProviderElement<BluetoothScannerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BluetoothScannerService create(Ref ref) {
    return bluetoothScannerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothScannerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothScannerService>(value),
    );
  }
}

String _$bluetoothScannerServiceHash() =>
    r'f6b53cee1ef5149f35c0382415691d207436db4b';

/// Exposes a reactive stream of all discovered BLE devices filtered and mapped by infrastructure.

@ProviderFor(bleScanResults)
final bleScanResultsProvider = BleScanResultsProvider._();

/// Exposes a reactive stream of all discovered BLE devices filtered and mapped by infrastructure.

final class BleScanResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BleDevice>>,
          List<BleDevice>,
          Stream<List<BleDevice>>
        >
    with $FutureModifier<List<BleDevice>>, $StreamProvider<List<BleDevice>> {
  /// Exposes a reactive stream of all discovered BLE devices filtered and mapped by infrastructure.
  BleScanResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleScanResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleScanResultsHash();

  @$internal
  @override
  $StreamProviderElement<List<BleDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BleDevice>> create(Ref ref) {
    return bleScanResults(ref);
  }
}

String _$bleScanResultsHash() => r'6697cd852f1733f62b2a3e74ae68be3a59fd9e7b';

/// Controller managing the execution of hardware scan intents and tracking active scanner lifecycle.

@ProviderFor(BluetoothScannerController)
final bluetoothScannerControllerProvider =
    BluetoothScannerControllerProvider._();

/// Controller managing the execution of hardware scan intents and tracking active scanner lifecycle.
final class BluetoothScannerControllerProvider
    extends $StreamNotifierProvider<BluetoothScannerController, bool> {
  /// Controller managing the execution of hardware scan intents and tracking active scanner lifecycle.
  BluetoothScannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothScannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothScannerControllerHash();

  @$internal
  @override
  BluetoothScannerController create() => BluetoothScannerController();
}

String _$bluetoothScannerControllerHash() =>
    r'd6df71954e9add908d021ca6dc0f6d986d65f70c';

/// Controller managing the execution of hardware scan intents and tracking active scanner lifecycle.

abstract class _$BluetoothScannerController extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
