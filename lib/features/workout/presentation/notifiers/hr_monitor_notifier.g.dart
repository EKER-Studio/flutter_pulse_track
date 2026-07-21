// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_monitor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider that manages the heart-rate monitoring lifecycle.
///
/// Scans for BLE devices, connects to the first heart-rate sensor it finds,
/// subscribes to its heart-rate characteristic, and exposes the collected BPM
/// samples as a reactive [AsyncValue] stream.
///
/// Periodically checkpoints accumulated BPM samples to Isar every 30 seconds
/// to prevent data loss if the process is terminated while the app is in the
/// background. On lifecycle transitions to [AppLifecycleState.paused] or
/// [AppLifecycleState.detached], the current session is synchronously flushed
/// to disk before the app leaves the foreground.

@ProviderFor(HrMonitorNotifier)
final hrMonitorProvider = HrMonitorNotifierProvider._();

/// Riverpod provider that manages the heart-rate monitoring lifecycle.
///
/// Scans for BLE devices, connects to the first heart-rate sensor it finds,
/// subscribes to its heart-rate characteristic, and exposes the collected BPM
/// samples as a reactive [AsyncValue] stream.
///
/// Periodically checkpoints accumulated BPM samples to Isar every 30 seconds
/// to prevent data loss if the process is terminated while the app is in the
/// background. On lifecycle transitions to [AppLifecycleState.paused] or
/// [AppLifecycleState.detached], the current session is synchronously flushed
/// to disk before the app leaves the foreground.
final class HrMonitorNotifierProvider
    extends $AsyncNotifierProvider<HrMonitorNotifier, void> {
  /// Riverpod provider that manages the heart-rate monitoring lifecycle.
  ///
  /// Scans for BLE devices, connects to the first heart-rate sensor it finds,
  /// subscribes to its heart-rate characteristic, and exposes the collected BPM
  /// samples as a reactive [AsyncValue] stream.
  ///
  /// Periodically checkpoints accumulated BPM samples to Isar every 30 seconds
  /// to prevent data loss if the process is terminated while the app is in the
  /// background. On lifecycle transitions to [AppLifecycleState.paused] or
  /// [AppLifecycleState.detached], the current session is synchronously flushed
  /// to disk before the app leaves the foreground.
  HrMonitorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hrMonitorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hrMonitorNotifierHash();

  @$internal
  @override
  HrMonitorNotifier create() => HrMonitorNotifier();
}

String _$hrMonitorNotifierHash() => r'c5171c3f8d1f5dc613bfcffa4732c32d4969f30c';

/// Riverpod provider that manages the heart-rate monitoring lifecycle.
///
/// Scans for BLE devices, connects to the first heart-rate sensor it finds,
/// subscribes to its heart-rate characteristic, and exposes the collected BPM
/// samples as a reactive [AsyncValue] stream.
///
/// Periodically checkpoints accumulated BPM samples to Isar every 30 seconds
/// to prevent data loss if the process is terminated while the app is in the
/// background. On lifecycle transitions to [AppLifecycleState.paused] or
/// [AppLifecycleState.detached], the current session is synchronously flushed
/// to disk before the app leaves the foreground.

abstract class _$HrMonitorNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
