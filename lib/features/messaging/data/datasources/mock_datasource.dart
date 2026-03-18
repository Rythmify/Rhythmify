import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

class MockDatasourceImplement implements DatasourceInterface {
  final List<ConversationModel> _conversations = [
    ConversationModel(
      conversationId: 'c1',
      participantId: 'u2',
      participantName: 'Ali',
      participantAvatar: null,
      lastMessagePreview: 'Hey Rana!',
      lastMessageDate: DateTime.now().subtract(const Duration(minutes: 10)),
      unReadCount: 2,
    ),
    ConversationModel(
      conversationId: 'c2',
      participantId: 'u3',
      participantName: 'Mona',
      participantAvatar: null,
      lastMessagePreview: 'Did you finish?',
      lastMessageDate: DateTime.now().subtract(const Duration(hours: 1)),
      unReadCount: 0,
    ),
  ];

  final Map<String, List<MessageModel>> _messagesByConversation = {
    'c1': [
      MessageModel(
        messageId: 'm1',
        conversationId: 'c1',
        senderId: 'u2',
        body: 'Hey Rana!',
        embedType: null,
        embedId: null,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      MessageModel(
        messageId: 'm2',
        conversationId: 'c1',
        senderId: 'current_user',
        body: 'Hi Ali',
        embedType: null,
        embedId: null,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      MessageModel(
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
      MessageModel(
        messageId: 'm4',
        conversationId: 'c2',
        senderId: 'u3',
        body: 'Did you finish?',
        embedType: null,
        embedId: null,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };

  @override
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_conversations);
  }

  @override
  Future<List<MessageModel>> getMessages({required String conversationId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_messagesByConversation[conversationId] ?? []);
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required SentMessageRequestModel requestContent,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final newMessage = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: 'current_user',
      body: requestContent.body,
      embedType: null,
      embedId: null,
      isRead: true,
      createdAt: DateTime.now(),
    );

    final oldList = _messagesByConversation[conversationId] ?? [];
    _messagesByConversation[conversationId] = [...oldList, newMessage];

    final index = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = ConversationModel(
        conversationId: old.conversationId,
        participantId: old.participantId,
        participantName: old.participantName,
        participantAvatar: old.participantAvatar,
        lastMessagePreview: newMessage.body,
        lastMessageDate: newMessage.createdAt,
        unReadCount: old.unReadCount,
      );
    }

    return newMessage;
  }

  @override
  Future<ConversationModel> newConversation({required String participantId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final newConv = ConversationModel(
      conversationId: DateTime.now().millisecondsSinceEpoch.toString(),
      participantId: participantId,
      participantName: 'New User',
      participantAvatar: null,
      lastMessagePreview: '',
      lastMessageDate: DateTime.now(),
      unReadCount: 0,
    );

    _conversations.insert(0, newConv);
    _messagesByConversation[newConv.conversationId] = [];
    return newConv;
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _conversations.fold<int>(0, (sum, c) => sum + c.unReadCount);
  }

  @override
  Future<void> blockUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> unBlockUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final list = _messagesByConversation[conversationId];
    if (list == null) return;

    _messagesByConversation[conversationId] = list
        .map(
          (m) => MessageModel(
            messageId: m.messageId,
            conversationId: m.conversationId,
            senderId: m.senderId,
            body: m.body,
            embedType: m.embedType,
            embedId: m.embedId,
            isRead: true,
            createdAt: m.createdAt,
          ),
        )
        .toList();

    final index = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = ConversationModel(
        conversationId: old.conversationId,
        participantId: old.participantId,
        participantName: old.participantName,
        participantAvatar: old.participantAvatar,
        lastMessagePreview: old.lastMessagePreview,
        lastMessageDate: old.lastMessageDate,
        unReadCount: 0,
      );
    }
  }
}