import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';

class SettingsDatasourcesImpl implements SettingsRemoteDatasources {
  final ApiClient _apiClient;

  SettingsDatasourcesImpl(this._apiClient);

  @override
  Future<PrivacySettingsModel> getPrivacySettings() async {
    final response = await _apiClient.dio.get('/users/me/privacy-settings');
    return PrivacySettingsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PrivacySettingsModel> updatePrivacySettings(
    PrivacySettingsModel privacy,
  ) async {
    final response = await _apiClient.dio.patch(
      '/users/me/privacy-settings',
      data: privacy.toJson(),
    );
    return PrivacySettingsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    final response = await _apiClient.dio.get('/notifications/preferences');
    return NotificationPreferencesModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel notificationPreferences,
  ) async {
    final response = await _apiClient.dio.patch(
      '/notifications/preferences',
      data: notificationPreferences.toJson(),
    );
    return NotificationPreferencesModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteMyAccount() async {
    await _apiClient.dio.delete('/users/me');
  }
}
