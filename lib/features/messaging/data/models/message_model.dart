import 'package:rythmify/features/messaging/domain/entities/message.dart';

/// Data model representing a [Message].
///
/// This class extends [Message] and provides methods for JSON serialization
/// and deserialization to interact with the [RemoteDataSource].
class MessageModel extends Message {
  MessageModel({
    required super.messageId,
    required super.conversationId,
    required super.senderId,
    super.body,
    super.embedId,
    super.embedType,
    required super.isRead,
    required super.createdAt,
  });

  /// Factory constructor to create a [MessageModel] from a JSON object.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      body: json['body'],
      embedId: json['embed_id'],
      embedType: json['embed_type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Converts this [MessageModel] instance into a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'body': body,
      'embed_id': embedId,
      'embed_type': embedType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
