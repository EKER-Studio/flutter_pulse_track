// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages application-wide user settings and provides methods to mutate preferences.

@ProviderFor(AppSettingsNotifier)
final appSettingsProvider = AppSettingsNotifierProvider._();

/// Manages application-wide user settings and provides methods to mutate preferences.
final class AppSettingsNotifierProvider
    extends $NotifierProvider<AppSettingsNotifier, UserSettings> {
  /// Manages application-wide user settings and provides methods to mutate preferences.
  AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettings>(value),
    );
  }
}

String _$appSettingsNotifierHash() =>
    r'30774e3073425a40b6ee245cb90a3f18c96e0c7b';

/// Manages application-wide user settings and provides methods to mutate preferences.

abstract class _$AppSettingsNotifier extends $Notifier<UserSettings> {
  UserSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserSettings, UserSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserSettings, UserSettings>,
              UserSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
