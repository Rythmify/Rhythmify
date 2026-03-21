import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

class PotentialConversationModel extends PotentialConversation{
  PotentialConversationModel({
    required super.participantId,
    required super.participantName,
    super.followersCount,
    super.location,
    super.avatar
  });

  factory PotentialConversationModel.fromJson(Map<String,dynamic> json)
  {
    return PotentialConversationModel(
      participantId: json['id'],
      participantName: json['display_name'],
      followersCount: json['follower_count'],
      avatar: json['avatar'],
      location: null //TO BE CHANGED!!!!!!!!!!!!!!!!!
    );
  }
}