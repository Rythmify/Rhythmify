import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

final notificationPrefsProvider =
    AsyncNotifierProvider<
      NotificationPrefsNotifier,
      NotificationPreferencesEntity
    >(NotificationPrefsNotifier.new);

class NotificationPrefsNotifier
    extends AsyncNotifier<NotificationPreferencesEntity> {
  @override
  Future<NotificationPreferencesEntity> build() {
    return ref.watch(settingsRepositoryProvider).getNotificationPreferences();
  }

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
