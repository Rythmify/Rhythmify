import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

/// Provides and manages the current user's notification preferences.
///
/// Loads preferences on first access and keeps them in sync after [save] calls.
final notificationPrefsProvider =
    AsyncNotifierProvider<
      NotificationPrefsNotifier,
      NotificationPreferencesEntity
    >(NotificationPrefsNotifier.new);

/// Notifier for notification preferences with optimistic UI updates.
///
/// On [save], the state is immediately updated to the new value so the UI
/// reflects the change without waiting for the network. If the request fails,
/// the previous state is restored and the error is surfaced.
class NotificationPrefsNotifier
    extends AsyncNotifier<NotificationPreferencesEntity> {
  @override
  /// Fetches preferences from the repository on initial load.
  Future<NotificationPreferencesEntity> build() {
    return ref.watch(settingsRepositoryProvider).getNotificationPreferences();
  }

  /// Persists [updated] preferences and applies an optimistic local update.
  ///
  /// Reverts to the previous state and emits [AsyncError] if the request fails.
  Future<void> save(NotificationPreferencesEntity updated) async {
    final previous = state;
    state = AsyncData(updated);
    try {
      final saved = await ref
          .read(settingsRepositoryProvider)
          .updateNotificationPreferences(updated);
      state = AsyncData(saved);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
    }
  }
}
