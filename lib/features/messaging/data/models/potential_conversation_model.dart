import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

/// Data model representing a [PotentialConversation].
///
/// This class extends [PotentialConversation] and provides methods for JSON 
/// deserialization to interact with the [RemoteDataSource].
class PotentialConversationModel extends PotentialConversation {
  PotentialConversationModel({
    required super.participantId,
    required super.participantName,
    super.followersCount,
    super.location,
    super.avatar,
  });

  /// Factory constructor to create a [PotentialConversationModel] from a JSON object.
  factory PotentialConversationModel.fromJson(Map<String, dynamic> json) {
    return PotentialConversationModel(
      participantId: json['id'] ?? json['user_id'],
      participantName: json['display_name'],
      followersCount: json['follower_count'],
      avatar: json['avatar'],
      location: null, //TO BE CHANGED!!!!!!!!!!!!!!!!!
    );
  }
}
