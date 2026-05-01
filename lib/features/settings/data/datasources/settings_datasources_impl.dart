import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';

/// HTTP implementation of [SettingsRemoteDatasources] using [ApiClient].
///
/// All endpoints are relative to the base URL configured in [ApiClient].
class SettingsDatasourcesImpl implements SettingsRemoteDatasources {
  final ApiClient _apiClient;

  SettingsDatasourcesImpl(this._apiClient);

  @override
  /// Fetches privacy settings from `GET /users/me/privacy-settings`.
  ///
  /// Falls back to an empty map when the response `data` field is absent,
  /// so [PrivacySettingsModel.fromJson] can apply its own defaults.
  Future<PrivacySettingsModel> getPrivacySettings() async {
    final response = await _apiClient.dio.get('/users/me/privacy-settings');
    final data = response.data;
    final map = (data is Map && data['data'] != null)
        ? data['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return PrivacySettingsModel.fromJson(map);
  }

  @override
  /// Applies [fields] as a partial update via `PATCH /users/me/privacy-settings`.
  ///
  /// Only the keys present in [fields] are sent; the server merges them with
  /// existing values. Falls back to an empty map if `data` is absent.
  Future<PrivacySettingsModel> patchPrivacySettings(
    Map<String, dynamic> fields,
  ) async {
    final response = await _apiClient.dio.patch(
      '/users/me/privacy-settings',
      data: fields,
    );
    final data = response.data;
    final map = (data is Map && data['data'] != null)
        ? data['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return PrivacySettingsModel.fromJson(map);
  }

  @override
  /// Fetches notification preferences from `GET /notifications/preferences`.
  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    final response = await _apiClient.dio.get('/notifications/preferences');
    return NotificationPreferencesModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  /// Persists [notificationPreferences] via `PATCH /notifications/preferences`.
  ///
  /// Serialises the full preferences object; the server replaces all preference fields.
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
  /// Permanently deletes the authenticated user's account via `DELETE /users/me`.
  Future<void> deleteMyAccount() async {
    await _apiClient.dio.delete('/users/me');
  }
}
