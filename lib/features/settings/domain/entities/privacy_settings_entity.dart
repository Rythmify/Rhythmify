import 'package:equatable/equatable.dart';

class PrivacySettingsEntity extends Equatable{
  final bool isPrivate;
  final bool receiveMessageFromAnyone;
  final bool showActivitiesInDiscovery;
  final bool showAsTopFan;
  final bool showTopFansOnTracks;
  const PrivacySettingsEntity({
    required this.isPrivate,
    required this.receiveMessageFromAnyone,
    required this.showActivitiesInDiscovery,
    required this.showAsTopFan,
    required this.showTopFansOnTracks
  });

  PrivacySettingsEntity copyWith({
    bool? isPrivate,
    bool? receiveMessageFromAnyone,
    bool? showActivitiesInDiscovery,
    bool? showAsTopFan,
    bool? showTopFansOnTracks
  }){
    return PrivacySettingsEntity(
      isPrivate: isPrivate?? this.isPrivate,
      receiveMessageFromAnyone: receiveMessageFromAnyone?? this.receiveMessageFromAnyone,
      showActivitiesInDiscovery: showActivitiesInDiscovery?? this.showActivitiesInDiscovery,
      showAsTopFan: showAsTopFan?? this.showAsTopFan,
      showTopFansOnTracks: showTopFansOnTracks?? this.showTopFansOnTracks
    );
  }

  @override
  List<Object?> get props => [
    isPrivate,
    receiveMessageFromAnyone,
    showActivitiesInDiscovery,
    showAsTopFan,
    showTopFansOnTracks
  ];
}