import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

/// Data model representing a [PotentialConversation].
///
/// This class extends [PotentialConversation] and provides methods for JSON
/// deserialization to interact with the [RemoteDataSource].
class FollowStatusModel {
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isBlocked;
  final bool isBlockby;

  FollowStatusModel({
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isBlocked,
    required this.isBlockby
  });

  /// Factory constructor to create a [FollowStatusModel] from a JSON object.
  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowStatusModel(
      isFollowing: json['is_following'],
      isFollowedBy: json['is_followed_by'],
      isBlocked: json['is_blocking'],
      isBlockby: json['is_blocked_by']
    );
  }

  
}
