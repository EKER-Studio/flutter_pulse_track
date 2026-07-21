// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BleScannerNotifier)
final bleScannerProvider = BleScannerNotifierProvider._();

final class BleScannerNotifierProvider
    extends $NotifierProvider<BleScannerNotifier, BleScannerState> {
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
    r'69d026b782f1b9c9b1eafc913c4853a89bd48b0a';

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
