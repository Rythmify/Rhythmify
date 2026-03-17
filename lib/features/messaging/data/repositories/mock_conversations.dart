import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

final List<Conversation> mockConversations = [
  Conversation(
    conversationId: 'c1',
    participantId: 'u1',
    participantName: 'Lina',
    participantAvatar: null,
    lastMessagePreview: 'It has been stuck in my head all day',
    lastMessageDate: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
    unReadCount: 1,
  ),
  Conversation(
    conversationId: 'c2',
    participantId: 'u2',
    participantName: 'Omar',
    participantAvatar: null,
    lastMessagePreview: 'We need to finish the UI today',
    lastMessageDate: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
    unReadCount: 2,
  ),
  Conversation(
    conversationId: 'c3',
    participantId: 'u3',
    participantName: 'Mariam',
    participantAvatar: null,
    lastMessagePreview: 'Perfect, I will review them now',
    lastMessageDate: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 20)),
    unReadCount: 0,
  ),
  Conversation(
    conversationId: 'c4',
    participantId: 'u4',
    participantName: 'Youssef',
    participantAvatar: null,
    lastMessagePreview: 'Great, see you there',
    lastMessageDate: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 10)),
    unReadCount: 0,
  ),
  Conversation(
    conversationId: 'c5',
    participantId: 'u5',
    participantName: 'Salma',
    participantAvatar: null,
    lastMessagePreview: 'Can you send me the final screenshot?',
    lastMessageDate: DateTime.now().subtract(const Duration(minutes: 35)),
    unReadCount: 1,
  ),
];