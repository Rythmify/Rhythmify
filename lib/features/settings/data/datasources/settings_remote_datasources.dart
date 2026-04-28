import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';

abstract class SettingsRemoteDatasources {
  Future<PrivacySettingsModel> getPrivacySettings();
  Future<PrivacySettingsModel> updatePrivacySettings(
    PrivacySettingsModel privacy,
  );
  Future<NotificationPreferencesModel> getNotificationPreferences();
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel notificationPreferences,
  );
  Future<void> deleteMyAccount();
}
