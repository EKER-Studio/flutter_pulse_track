// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages BLE scanning lifecycle and filters discovered devices.
///
/// Auto-disposed when the scanner view is popped; [_cleanup] stops the
/// hardware scan and cancels all subscriptions, so no radio or battery
/// resources leak beyond the view lifetime.

@ProviderFor(BleScannerNotifier)
final bleScannerProvider = BleScannerNotifierProvider._();

/// Manages BLE scanning lifecycle and filters discovered devices.
///
/// Auto-disposed when the scanner view is popped; [_cleanup] stops the
/// hardware scan and cancels all subscriptions, so no radio or battery
/// resources leak beyond the view lifetime.
final class BleScannerNotifierProvider
    extends $NotifierProvider<BleScannerNotifier, BleScannerState> {
  /// Manages BLE scanning lifecycle and filters discovered devices.
  ///
  /// Auto-disposed when the scanner view is popped; [_cleanup] stops the
  /// hardware scan and cancels all subscriptions, so no radio or battery
  /// resources leak beyond the view lifetime.
  BleScannerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleScannerNotifierHash();

  @$internal
  @override
  BleScannerNotifier create() => BleScannerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleScannerState>(value),
    );
  }
}

String _$bleScannerNotifierHash() =>
    r'1e835b94b72e8234a9be769fe929f89f9a137470';

/// Manages BLE scanning lifecycle and filters discovered devices.
///
/// Auto-disposed when the scanner view is popped; [_cleanup] stops the
/// hardware scan and cancels all subscriptions, so no radio or battery
/// resources leak beyond the view lifetime.

abstract class _$BleScannerNotifier extends $Notifier<BleScannerState> {
  BleScannerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BleScannerState, BleScannerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleScannerState, BleScannerState>,
              BleScannerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
