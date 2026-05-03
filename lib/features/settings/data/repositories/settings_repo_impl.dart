import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';
import 'package:rythmify/features/settings/domain/repositories/settings_repo_interface.dart';

/// Concrete implementation of [SettingsRepoInterface].
///
/// Converts between domain entities and data models before delegating
/// to [SettingsRemoteDatasources]. The entity↔model conversions are
/// handled by the model factories ([fromEntity], [toDomain]).
class SettingsRepoImpl implements SettingsRepoInterface {
  final SettingsRemoteDatasources _datasource;

  SettingsRepoImpl(this._datasource);

  @override
  /// Fetches privacy settings and converts the model to a domain entity.
  Future<PrivacySettingsEntity> getPrivacySettings() async {
    final model = await _datasource.getPrivacySettings();
    return model.toDomain();
  }

  @override
  /// Computes the diff between [previous] and [updated], then PATCHes only changed fields.
  ///
  /// Returns [updated] immediately if no fields changed, avoiding a redundant network call.
  Future<PrivacySettingsEntity> updatePrivacySettings(
    PrivacySettingsEntity previous,
    PrivacySettingsEntity updated,
  ) async {
    final previousModel = PrivacySettingsModel.fromEntity(previous);
    final updatedModel = PrivacySettingsModel.fromEntity(updated);
    final patch = updatedModel.toPatch(previousModel);
    if (patch.isEmpty) return updated;
    final model = await _datasource.patchPrivacySettings(patch);
    return model.toDomain();
  }

  @override
  /// Fetches notification preferences and converts the model to a domain entity.
  Future<NotificationPreferencesEntity> getNotificationPreferences() async {
    final model = await _datasource.getNotificationPreferences();
    return model.toDomain();
  }

  @override
  /// Converts [notificationPreferences] to a model, persists it, and returns the saved entity.
  Future<NotificationPreferencesEntity> updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences,
  ) async {
    final model = await _datasource.updateNotificationPreferences(
      NotificationPreferencesModel.fromEntity(notificationPreferences),
    );
    return model.toDomain();
  }

  @override
  /// Permanently deletes the authenticated user's account.
  Future<void> deleteMyAccount() async {
    await _datasource.deleteMyAccount();
  }
}
