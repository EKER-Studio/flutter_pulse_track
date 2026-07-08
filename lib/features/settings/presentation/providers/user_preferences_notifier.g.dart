// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserPreferencesNotifier)
final userPreferencesProvider = UserPreferencesNotifierProvider._();

final class UserPreferencesNotifierProvider
    extends $AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences> {
  UserPreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesNotifierHash();

  @$internal
  @override
  UserPreferencesNotifier create() => UserPreferencesNotifier();
}

String _$userPreferencesNotifierHash() =>
    r'c32251a1f9b53af706d3687f208f10e663f58b10';

abstract class _$UserPreferencesNotifier
    extends $AsyncNotifier<UserPreferences> {
  FutureOr<UserPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserPreferences>, UserPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserPreferences>, UserPreferences>,
              AsyncValue<UserPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
