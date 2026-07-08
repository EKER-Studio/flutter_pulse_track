import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_preferences.dart';
import 'user_preferences_repository_provider.dart';

part 'user_preferences_notifier.g.dart';

@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  Future<UserPreferences> build() async {
    final repository = ref.watch(userPreferencesRepositoryProvider);
    final completer = Completer<UserPreferences>();

    final subscription = repository.watch().listen(
      (preferences) {
        if (!completer.isCompleted) {
          completer.complete(preferences);
        }
        state = AsyncData(preferences);
      },
      onError: (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(subscription.cancel);

    return completer.future;
  }

  Future<void> updateThemeMode(UserThemeMode themeMode) async {
    try {
      await ref
          .read(userPreferencesRepositoryProvider)
          .updateThemeMode(themeMode);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> updateNotificationsEnabled(bool isEnabled) async {
    try {
      await ref
          .read(userPreferencesRepositoryProvider)
          .updateNotificationsEnabled(isEnabled);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
