import 'package:rythmify/features/messaging/domain/entities/message.dart';

final List<Message> mockMessages = [
  // c1
  Message(
    messageId: 'm1',
    senderId: 'u1',
    conversationId: 'c1',
    body: 'Hey, did you listen to the track I sent?',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Message(
    messageId: 'm2',
    senderId: 'current_user',
    conversationId: 'c1',
    body: 'Yes, I liked it a lot actually',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
  ),
  Message(
    messageId: 'm3',
    senderId: 'u1',
    conversationId: 'c1',
    body: 'It has been stuck in my head all day',
    embedId: null,
    embedType: null,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
  ),

  // c2
  Message(
    messageId: 'm4',
    senderId: 'u2',
    conversationId: 'c2',
    body: 'Are you free tonight?',
    embedId: null,
    embedType: null,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
  ),
  Message(
    messageId: 'm5',
    senderId: 'u2',
    conversationId: 'c2',
    body: 'We need to finish the UI today',
    embedId: null,
    embedType: null,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
  ),

  // c3
  Message(
    messageId: 'm6',
    senderId: 'current_user',
    conversationId: 'c3',
    body: 'I pushed the changes to my branch',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Message(
    messageId: 'm7',
    senderId: 'u3',
    conversationId: 'c3',
    body: 'Perfect, I will review them now',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 20)),
  ),

  // c4
  Message(
    messageId: 'm8',
    senderId: 'u4',
    conversationId: 'c4',
    body: 'Don’t forget tomorrow’s meeting',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
  ),
  Message(
    messageId: 'm9',
    senderId: 'current_user',
    conversationId: 'c4',
    body: 'I won’t, thanks for reminding me',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 45)),
  ),
  Message(
    messageId: 'm10',
    senderId: 'u4',
    conversationId: 'c4',
    body: 'Great, see you there',
    embedId: null,
    embedType: null,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 10)),
  ),

  // c5
  Message(
    messageId: 'm11',
    senderId: 'u5',
    conversationId: 'c5',
    body: 'Can you send me the final screenshot?',
    embedId: null,
    embedType: null,
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
  ),
];