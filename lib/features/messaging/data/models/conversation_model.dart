import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

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

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>? ?? {};
    final lastMessage = json['last_message'] as Map<String, dynamic>? ?? {};

    return ConversationModel(
      conversationId: json['id'] ?? '',
      participantId: participant['id'] ?? '',
      participantName: participant['display_name'] ?? 'Unknown',
      participantAvatar: participant['profile_picture'],
      lastMessagePreview: lastMessage['body'] ?? '',
      lastMessageDate: lastMessage['created_at'] != null
          ? DateTime.tryParse(lastMessage['created_at']) ?? DateTime.now()
          : DateTime.now(),

      unReadCount: json['unread_count'] as int? ?? 0,
    );
  }

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
