import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';

abstract class SettingsRepoInterface {
  Future<PrivacySettingsEntity> getPrivacySettings();
  Future<PrivacySettingsEntity> updatePrivacySettings(
    PrivacySettingsEntity privacy,
  );
  Future<NotificationPreferencesEntity> getNotificationPreferences();
  Future<NotificationPreferencesEntity> updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences,
  );
  Future<void> deleteMyAccount();
}
