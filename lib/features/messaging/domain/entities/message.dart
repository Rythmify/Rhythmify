class Message {
  final String messageId;
  final String senderId;
  final String conversationId;
  final String? body;
  final String? embedId;
  final String? embedType;
  final bool isRead; //default false
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
}
