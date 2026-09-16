// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton Riverpod provider delivering the [BluetoothScannerService] using [ref].

@ProviderFor(bluetoothScannerService)
final bluetoothScannerServiceProvider = BluetoothScannerServiceProvider._();

/// Singleton Riverpod provider delivering the [BluetoothScannerService] using [ref].

final class BluetoothScannerServiceProvider
    extends
        $FunctionalProvider<
          BluetoothScannerService,
          BluetoothScannerService,
          BluetoothScannerService
        >
    with $Provider<BluetoothScannerService> {
  /// Singleton Riverpod provider delivering the [BluetoothScannerService] using [ref].
  BluetoothScannerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothScannerServiceProvider',
        isAutoDispose: false,
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
    r'32cf1f6ae5187f8994adc81de37da12efb864fbe';

/// Singleton Riverpod provider delivering the [HeartRateMonitorService] using [ref].

@ProviderFor(heartRateMonitorService)
final heartRateMonitorServiceProvider = HeartRateMonitorServiceProvider._();

/// Singleton Riverpod provider delivering the [HeartRateMonitorService] using [ref].

final class HeartRateMonitorServiceProvider
    extends
        $FunctionalProvider<
          HeartRateMonitorService,
          HeartRateMonitorService,
          HeartRateMonitorService
        >
    with $Provider<HeartRateMonitorService> {
  /// Singleton Riverpod provider delivering the [HeartRateMonitorService] using [ref].
  HeartRateMonitorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heartRateMonitorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heartRateMonitorServiceHash();

  @$internal
  @override
  $ProviderElement<HeartRateMonitorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HeartRateMonitorService create(Ref ref) {
    return heartRateMonitorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HeartRateMonitorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HeartRateMonitorService>(value),
    );
  }
}

String _$heartRateMonitorServiceHash() =>
    r'016a78fda1f182e0716ef69471519f8eb3fe972a';
