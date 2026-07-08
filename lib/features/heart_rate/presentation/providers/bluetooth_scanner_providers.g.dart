// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_scanner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bluetoothScannerService)
final bluetoothScannerServiceProvider = BluetoothScannerServiceProvider._();

final class BluetoothScannerServiceProvider
    extends
        $FunctionalProvider<
          BluetoothScannerService,
          BluetoothScannerService,
          BluetoothScannerService
        >
    with $Provider<BluetoothScannerService> {
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

@ProviderFor(bleScanResults)
final bleScanResultsProvider = BleScanResultsProvider._();

final class BleScanResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BleDevice>>,
          List<BleDevice>,
          Stream<List<BleDevice>>
        >
    with $FutureModifier<List<BleDevice>>, $StreamProvider<List<BleDevice>> {
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

@ProviderFor(BluetoothScannerController)
final bluetoothScannerControllerProvider =
    BluetoothScannerControllerProvider._();

final class BluetoothScannerControllerProvider
    extends $StreamNotifierProvider<BluetoothScannerController, bool> {
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
    r'ff6786ac22a2eb940cc1105e5f5ae47f0f91d89e';

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
