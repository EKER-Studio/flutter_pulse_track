// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heart_rate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a HeartRateRepository instance scoped to a specific device configuration.

@ProviderFor(heartRateRepository)
final heartRateRepositoryProvider = HeartRateRepositoryFamily._();

/// Provides a HeartRateRepository instance scoped to a specific device configuration.

final class HeartRateRepositoryProvider
    extends
        $FunctionalProvider<
          HeartRateRepository,
          HeartRateRepository,
          HeartRateRepository
        >
    with $Provider<HeartRateRepository> {
  /// Provides a HeartRateRepository instance scoped to a specific device configuration.
  HeartRateRepositoryProvider._({
    required HeartRateRepositoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'heartRateRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$heartRateRepositoryHash();

  @override
  String toString() {
    return r'heartRateRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<HeartRateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HeartRateRepository create(Ref ref) {
    final argument = this.argument as String;
    return heartRateRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HeartRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HeartRateRepository>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HeartRateRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$heartRateRepositoryHash() =>
    r'068148fc23911b4a235a65f6015d0167e51f2050';

/// Provides a HeartRateRepository instance scoped to a specific device configuration.

final class HeartRateRepositoryFamily extends $Family
    with $FunctionalFamilyOverride<HeartRateRepository, String> {
  HeartRateRepositoryFamily._()
    : super(
        retry: null,
        name: r'heartRateRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a HeartRateRepository instance scoped to a specific device configuration.

  HeartRateRepositoryProvider call(String deviceId) =>
      HeartRateRepositoryProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'heartRateRepositoryProvider';
}

/// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
///
/// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
/// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
/// tears down native BLE notifications to preserve device battery.

@ProviderFor(heartRateMetrics)
final heartRateMetricsProvider = HeartRateMetricsFamily._();

/// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
///
/// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
/// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
/// tears down native BLE notifications to preserve device battery.

final class HeartRateMetricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HrMeasurement>,
          HrMeasurement,
          Stream<HrMeasurement>
        >
    with $FutureModifier<HrMeasurement>, $StreamProvider<HrMeasurement> {
  /// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
  ///
  /// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
  /// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
  /// tears down native BLE notifications to preserve device battery.
  HeartRateMetricsProvider._({
    required HeartRateMetricsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'heartRateMetricsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$heartRateMetricsHash();

  @override
  String toString() {
    return r'heartRateMetricsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<HrMeasurement> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HrMeasurement> create(Ref ref) {
    final argument = this.argument as String;
    return heartRateMetrics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HeartRateMetricsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$heartRateMetricsHash() => r'e9ad4e8c3f34f8c24ee101cd8ae39ca0071f5055';

/// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
///
/// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
/// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
/// tears down native BLE notifications to preserve device battery.

final class HeartRateMetricsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<HrMeasurement>, String> {
  HeartRateMetricsFamily._()
    : super(
        retry: null,
        name: r'heartRateMetricsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Exposes a clean stream of parsed heart rate measurements for the UI or persistence layer.
  ///
  /// Under the hood, subscribing to this stream triggers physical connection and GATT discovery
  /// via the infrastructure layer. Unsubscribing (e.g., leaving the monitor view) automatically
  /// tears down native BLE notifications to preserve device battery.

  HeartRateMetricsProvider call(String deviceId) =>
      HeartRateMetricsProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'heartRateMetricsProvider';
}
