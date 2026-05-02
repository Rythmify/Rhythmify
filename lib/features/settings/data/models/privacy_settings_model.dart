import '../../domain/entities/privacy_settings_entity.dart';

/// Data-layer representation of [PrivacySettingsEntity].
///
/// Adds [fromJson] for deserialising the API response, [toPatch] for computing
/// a minimal PATCH body containing only changed fields, and [fromEntity]/[toDomain]
/// for converting between domain and data types.
class PrivacySettingsModel extends PrivacySettingsEntity {
  const PrivacySettingsModel({
    required super.isPrivate,
    required super.receiveMessageFromAnyone,
    required super.showActivitiesInDiscovery,
    required super.showAsTopFan,
    required super.showTopFansOnTracks,
  });

  /// Deserialises from the `GET /users/me/privacy-settings` response body.
  ///
  /// All fields default to safe values when absent from the API response.
  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      isPrivate: json['is_private'] as bool? ?? false,
      receiveMessageFromAnyone:
          json['receive_messages_from_anyone'] as bool? ?? true,
      showActivitiesInDiscovery:
          json['show_activities_in_discovery'] as bool? ?? true,
      showAsTopFan: json['show_as_top_fan'] as bool? ?? true,
      showTopFansOnTracks: json['show_top_fans_on_tracks'] as bool? ?? true,
    );
  }

  /// Produces a minimal patch body containing only fields that differ from [previous].
  ///
  /// Sending only changed fields avoids overwriting server-side defaults for
  /// fields the client has not explicitly set (e.g. `show_as_top_fan`).
  Map<String, dynamic> toPatch(PrivacySettingsModel previous) {
    final patch = <String, dynamic>{};
    if (previous.receiveMessageFromAnyone != receiveMessageFromAnyone) {
      patch['receive_messages_from_anyone'] = receiveMessageFromAnyone;
    }
    if (previous.showActivitiesInDiscovery != showActivitiesInDiscovery) {
      patch['show_activities_in_discovery'] = showActivitiesInDiscovery;
    }
    if (previous.showAsTopFan != showAsTopFan) {
      patch['show_as_top_fan'] = showAsTopFan;
    }
    if (previous.showTopFansOnTracks != showTopFansOnTracks) {
      patch['show_top_fans_on_tracks'] = showTopFansOnTracks;
    }
    return patch;
  }

  /// Creates a model from a domain [entity], preserving all field values.
  factory PrivacySettingsModel.fromEntity(PrivacySettingsEntity entity) {
    return PrivacySettingsModel(
      isPrivate: entity.isPrivate,
      receiveMessageFromAnyone: entity.receiveMessageFromAnyone,
      showActivitiesInDiscovery: entity.showActivitiesInDiscovery,
      showAsTopFan: entity.showAsTopFan,
      showTopFansOnTracks: entity.showTopFansOnTracks,
    );
  }

  /// Converts this model to a pure domain [PrivacySettingsEntity].
  PrivacySettingsEntity toDomain() => PrivacySettingsEntity(
    isPrivate: isPrivate,
    receiveMessageFromAnyone: receiveMessageFromAnyone,
    showActivitiesInDiscovery: showActivitiesInDiscovery,
    showAsTopFan: showAsTopFan,
    showTopFansOnTracks: showTopFansOnTracks,
  );
}
