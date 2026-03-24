import 'package:rythmify/features/messaging/domain/entities/message.dart';

final Map<String, List<Message>> mockMessagesByConversation = {
  'c1': [
    Message(
      messageId: 'm1',
      conversationId: 'c1',
      senderId: 'u2',
      body: 'Hey!',
      embedType: null,
      embedId: null,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Message(
      messageId: 'm2',
      conversationId: 'c1',
      senderId: 'current_user',
      body: 'Hi Ali',
      embedType: null,
      embedId: null,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 13)),
    ),
    Message(
      messageId: 'm3',
      conversationId: 'c1',
      senderId: 'u2',
      body: 'How are you?',
      embedType: null,
      embedId: null,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ],
  'c2': [
    Message(
      messageId: 'm4',
      conversationId: 'c2',
      senderId: 'u3',
      body: 'Did you finish the task?',
      embedType: null,
      embedId: null,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ],
};
