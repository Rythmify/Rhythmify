import 'package:equatable/equatable.dart';

/// Immutable entity representing a user's privacy configuration.
///
/// Describes visibility and interaction rules for the account.
/// Use [copyWith] to derive updated copies; [PrivacySettingsModel.toPatch]
/// then computes only the changed fields for the PATCH request.
class PrivacySettingsEntity extends Equatable {
  /// Whether the account is private (followers must be approved).
  final bool isPrivate;

  /// Whether any user can send a direct message, or only followers.
  final bool receiveMessageFromAnyone;

  /// Whether the user's listening activity appears in the discovery feed.
  final bool showActivitiesInDiscovery;

  /// Whether the user is shown as a top fan on artists' profiles.
  final bool showAsTopFan;

  /// Whether the user's top-fan badge appears on individual track pages.
  final bool showTopFansOnTracks;
  const PrivacySettingsEntity({
    required this.isPrivate,
    required this.receiveMessageFromAnyone,
    required this.showActivitiesInDiscovery,
    required this.showAsTopFan,
    required this.showTopFansOnTracks,
  });

  /// Returns a copy of this entity with only the provided fields replaced.
  PrivacySettingsEntity copyWith({
    bool? isPrivate,
    bool? receiveMessageFromAnyone,
    bool? showActivitiesInDiscovery,
    bool? showAsTopFan,
    bool? showTopFansOnTracks,
  }) {
    return PrivacySettingsEntity(
      isPrivate: isPrivate ?? this.isPrivate,
      receiveMessageFromAnyone:
          receiveMessageFromAnyone ?? this.receiveMessageFromAnyone,
      showActivitiesInDiscovery:
          showActivitiesInDiscovery ?? this.showActivitiesInDiscovery,
      showAsTopFan: showAsTopFan ?? this.showAsTopFan,
      showTopFansOnTracks: showTopFansOnTracks ?? this.showTopFansOnTracks,
    );
  }

  @override
  List<Object?> get props => [
    isPrivate,
    receiveMessageFromAnyone,
    showActivitiesInDiscovery,
    showAsTopFan,
    showTopFansOnTracks,
  ];
}
