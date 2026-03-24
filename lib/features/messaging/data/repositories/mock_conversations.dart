import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

/// A list of mock [Conversation] objects for use in previews, tests, and development.
final List<Conversation> mockConversations = [
  Conversation(
    conversationId: 'c1',
    participantId: 'u2',
    participantName: 'Ali',
    participantAvatar: null,
    lastMessagePreview: 'Hey, how are you?',
    lastMessageDate: DateTime.now().subtract(const Duration(minutes: 10)),
    unReadCount: 2,
  ),
  Conversation(
    conversationId: 'c2',
    participantId: 'u3',
    participantName: 'Mona',
    participantAvatar: null,
    lastMessagePreview: 'Okayyy',
    lastMessageDate: DateTime.now().subtract(const Duration(hours: 1)),
    unReadCount: 0,
  ),
];
