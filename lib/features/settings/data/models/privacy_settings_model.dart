import '../../domain/entities/privacy_settings_entity.dart';

class PrivacySettingsModel extends PrivacySettingsEntity {
  const PrivacySettingsModel({
    required super.isPrivate,
    required super.receiveMessageFromAnyone,
    required super.showActivitiesInDiscovery,
    required super.showAsTopFan,
    required super.showTopFansOnTracks,
  });

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
    return patch;
  }

  factory PrivacySettingsModel.fromEntity(PrivacySettingsEntity entity) {
    return PrivacySettingsModel(
      isPrivate: entity.isPrivate,
      receiveMessageFromAnyone: entity.receiveMessageFromAnyone,
      showActivitiesInDiscovery: entity.showActivitiesInDiscovery,
      showAsTopFan: entity.showAsTopFan,
      showTopFansOnTracks: entity.showTopFansOnTracks,
    );
  }

  PrivacySettingsEntity toDomain() => PrivacySettingsEntity(
    isPrivate: isPrivate,
    receiveMessageFromAnyone: receiveMessageFromAnyone,
    showActivitiesInDiscovery: showActivitiesInDiscovery,
    showAsTopFan: showAsTopFan,
    showTopFansOnTracks: showTopFansOnTracks,
  );
}
