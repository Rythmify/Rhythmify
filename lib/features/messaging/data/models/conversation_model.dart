import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

/// Data model representing a [Conversation].
///
/// This class extends [Conversation] and provides methods for JSON serialization
/// and deserialization to interact with the [RemoteDataSource].
class ConversationModel extends Conversation {
  ConversationModel({
    required super.conversationId,
    required super.participantId,
    required super.participantName,
    super.participantAvatar,
    required super.lastMessagePreview,
    required super.lastMessageDate,
    required super.unReadCount,
  });

  /// Factory constructor to create a [ConversationModel] from a JSON object.
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>? ?? {};
    final lastMessage = json['last_message'] as Map<String, dynamic>? ?? {};

    return ConversationModel(
      conversationId: json['id'] ?? '',
      participantId: participant['id'] ?? '',
      participantName: participant['display_name'] ?? 'Unknown',
      participantAvatar:
          participant['profile_picture'] ??
          participant['avatar_url'] ??
          participant['avatar'],
      lastMessagePreview:
          lastMessage['body'] ??
          (lastMessage['embed_type'] == 'track'
              ? 'https://rythmify.com/tracks/${lastMessage['embed_id']}'
              : lastMessage['embed_type'] == 'playlist'
              ? 'https://rythmify.com/playlists/${lastMessage['embed_id']}'
              : lastMessage['embed_type'] == 'album'
              ? 'https://rythmify.com/playlists/${lastMessage['embed_id']}'
              : ''),
      lastMessageDate: lastMessage['created_at'] != null
          ? DateTime.tryParse(lastMessage['created_at']) ?? DateTime.now()
          : DateTime.now(),

      unReadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Converts this [ConversationModel] instance into a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': conversationId,
      'participant': {
        'id': participantId,
        'display_name': participantName,
        'profile_picture': participantAvatar,
      },
      'last_message': lastMessagePreview.isNotEmpty
          ? {
              'body': lastMessagePreview,
              'created_at': lastMessageDate.toIso8601String(),
            }
          : null,
      'unread_count': unReadCount,
    };
  }
}
