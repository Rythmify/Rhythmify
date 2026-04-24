/// Represents an individual message within a conversation.
///
/// This entity holds the content of a message, its sender information,
/// and metadata about its creation and read status.
class Message {
  /// The unique identifier for the message.
  final String messageId;

  /// The unique identifier of the user who sent the message.
  final String senderId;

  /// The unique identifier of the conversation this message belongs to.
  final String conversationId;

  /// The text content of the message. Can be null if the message contains only an embed.
  final String? body;

  /// The identifier of an embedded object (e.g., a track or playlist) shared in the message.
  final String? embedId;

  /// The type of embedded object (e.g., 'track', 'playlist').
  final String? embedType;

  /// Whether the message has been read by the recipient.
  final bool isRead;

  /// The timestamp of when the message was created.
  final DateTime createdAt;

  const Message({
    required this.messageId,
    required this.senderId,
    required this.conversationId,
    this.body,
    this.embedId,
    this.embedType,
    required this.isRead,
    required this.createdAt,
  });

  Message copyWith({bool? isRead}){
    return Message(
      messageId: messageId,
      senderId: senderId,
      conversationId: conversationId,
      body: body,
      embedId: embedId,
      embedType: embedType,
      isRead: isRead??this.isRead,
      createdAt: createdAt
    );
  }
}
