import 'dart:io';

/// Platform detection abstraction allowing runtime OS checks to be mocked in unit tests.
abstract class PlatformDetector {
  /// Whether the host operating system is Android.
  bool get isAndroid;

  /// Whether the host operating system is iOS.
  bool get isIOS;
}

/// Default implementation of [PlatformDetector] delegating to `dart:io`.
class NativePlatformDetector implements PlatformDetector {
  /// Creates a [NativePlatformDetector] instance.
  const NativePlatformDetector();

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;
}
