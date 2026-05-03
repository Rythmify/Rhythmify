import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';

/// Abstract contract for settings-related data operations.
///
/// Implemented by [SettingsRepoImpl], which converts between domain entities
/// and data models before delegating to [SettingsRemoteDatasources].
abstract class SettingsRepoInterface {
  /// Fetches the current user's privacy settings from the backend.
  Future<PrivacySettingsEntity> getPrivacySettings();

  /// Applies changed privacy fields to the backend.
  ///
  /// [previous] is diffed against [updated] by [PrivacySettingsModel.toPatch]
  /// so that only modified fields are sent in the PATCH body. Returns the
  /// server-confirmed entity, or [updated] if no fields changed.
  Future<PrivacySettingsEntity> updatePrivacySettings(
    PrivacySettingsEntity previous,
    PrivacySettingsEntity updated,
  );

  /// Fetches the current user's notification and messaging preferences.
  Future<NotificationPreferencesEntity> getNotificationPreferences();

  /// Persists [notificationPreferences] to the backend and returns the saved entity.
  Future<NotificationPreferencesEntity> updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences,
  );

  /// Permanently deletes the authenticated user's account.
  ///
  /// This operation is irreversible. The caller is responsible for signing
  /// the user out and clearing local state after this resolves.
  Future<void> deleteMyAccount();
}
