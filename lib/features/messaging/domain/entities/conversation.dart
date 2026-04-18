/// Represents a conversation between the current user and another participant.
///
/// This entity holds the summary information of a chat, including the participant's
/// details, the last message sent, and the count of unread messages.
class Conversation {
  /// The unique identifier for the conversation.
  final String conversationId;

  /// The unique identifier of the other participant in the conversation.
  final String participantId;

  /// The name of the other participant.
  final String participantName;

  /// The optional URL to the participant's avatar image.
  final String? participantAvatar;

  /// A preview of the most recent message in the conversation.
  final String lastMessagePreview;

  /// The timestamp of when the last message was sent or received.
  final DateTime lastMessageDate;

  /// The number of unread messages for the current user in this conversation.
  final int unReadCount;

  Conversation({
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessagePreview,
    required this.lastMessageDate,
    required this.unReadCount,
  });

  Conversation copyWith({String? participantName}){
    return Conversation(
      conversationId: conversationId,
      participantId: participantId,
      participantName: participantName?? this.participantName,
      lastMessagePreview: lastMessagePreview,
      lastMessageDate: lastMessageDate,
      unReadCount: unReadCount
    );
  }
}
