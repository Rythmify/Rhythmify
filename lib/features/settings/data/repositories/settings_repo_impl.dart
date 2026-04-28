import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';
import 'package:rythmify/features/settings/domain/repositories/settings_repo_interface.dart';

class SettingsRepoImpl implements SettingsRepoInterface {
  final SettingsRemoteDatasources _datasource;

  SettingsRepoImpl(this._datasource);

  @override
  Future<PrivacySettingsEntity> getPrivacySettings() async {
    final model = await _datasource.getPrivacySettings();
    return model.toDomain();
  }

  @override
  Future<PrivacySettingsEntity> updatePrivacySettings(
    PrivacySettingsEntity privacy,
  ) async {
    final model = await _datasource.updatePrivacySettings(
      PrivacySettingsModel.fromEntity(privacy),
    );
    return model.toDomain();
  }

  @override
  Future<NotificationPreferencesEntity> getNotificationPreferences() async {
    final model = await _datasource.getNotificationPreferences();
    return model.toDomain();
  }

  @override
  Future<NotificationPreferencesEntity> updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences,
  ) async {
    final model = await _datasource.updateNotificationPreferences(
      NotificationPreferencesModel.fromEntity(notificationPreferences),
    );
    return model.toDomain();
  }

  @override
  Future<void> deleteMyAccount() async {
    await _datasource.deleteMyAccount();
  }
}
