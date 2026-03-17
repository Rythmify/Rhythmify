import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/data/repositories/mock_messages.dart';
import 'package:rythmify/features/messaging/data/repositories/mock_conversations.dart';

class RepositoryImplementMock implements MessagingRepository {
  // static so data stays changed even if repo object is recreated
  static List<Conversation> _conversations = List<Conversation>.from(mockConversations);
  static List<Message> _messages = List<Message>.from(mockMessages);
  static final Set<String> _blockedUsers = {};

  static const String _currentUserId = 'current_user';

  @override
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(Duration.zero);

    final visibleConversations = _conversations
        .where((conv) => !_blockedUsers.contains(conv.participantId))
        .toList();

    visibleConversations.sort((a, b) {
      final aDate = a.lastMessageDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastMessageDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return visibleConversations;
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(Duration.zero);

    final temp = _messages
        .where((msg) => msg.conversationId == conversationId)
        .toList();

    temp.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return temp;
  }

  @override
  Future<Conversation> startConversation(String participantId) async {
    await Future.delayed(Duration.zero);

    final existing = _conversations.where((c) => c.participantId == participantId).toList();
    if (existing.isNotEmpty) {
      return existing.first;
    }

    final newConversation = Conversation(
      conversationId: 'c${_conversations.length + 1}',
      participantId: participantId,
      participantName: participantId, // temporary fallback
      participantAvatar: null,
      lastMessagePreview: '',
      lastMessageDate: null,
      unReadCount: 0,
    );

    _conversations = [..._conversations, newConversation];
    return newConversation;
  }


@override
Future<Message> sendMessage(Message message) async {
  await Future.delayed(Duration.zero);

  _messages = [..._messages, message];

  _updateConversationAfterMessage(
    conversationId: message.conversationId,
    newPreview: message.body ?? '',
    newDate: message.createdAt,
  );

  return message;
}

  @override
  Future<void> blockUser(String participantId) async {
    await Future.delayed(Duration.zero);
    _blockedUsers.add(participantId);
  }

  @override
  Future<void> unBlockUser(String participantId) async {
    await Future.delayed(Duration.zero);
    _blockedUsers.remove(participantId);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await Future.delayed(Duration.zero);

    Message? updatedMessage;

    _messages = _messages.map((msg) {
      if (msg.messageId == messageId) {
        updatedMessage = Message(
          messageId: msg.messageId,
          senderId: msg.senderId,
          conversationId: msg.conversationId,
          body: msg.body,
          embedId: msg.embedId,
          embedType: msg.embedType,
          isRead: true,
          createdAt: msg.createdAt,
        );
        return updatedMessage!;
      }
      return msg;
    }).toList();

    if (updatedMessage != null) {
      _recalculateConversationUnread(updatedMessage!.conversationId);
    }
  }

  @override
  Future<int> getUnReadCount() async {
    await Future.delayed(Duration.zero);

    final unreadCount = _messages.where((msg) {
      return msg.senderId != _currentUserId && !msg.isRead;
    }).length;

    return unreadCount;
  }

  void _recalculateConversationUnread(String conversationId) {
    final unreadCount = _messages.where((msg) {
      return msg.conversationId == conversationId &&
          msg.senderId != _currentUserId &&
          !msg.isRead;
    }).length;

    _conversations = _conversations.map((conv) {
      if (conv.conversationId == conversationId) {
        return Conversation(
          conversationId: conv.conversationId,
          participantId: conv.participantId,
          participantName: conv.participantName,
          participantAvatar: conv.participantAvatar,
          lastMessagePreview: conv.lastMessagePreview,
          lastMessageDate: conv.lastMessageDate,
          unReadCount: unreadCount,
        );
      }
      return conv;
    }).toList();
  }

  void _updateConversationAfterMessage({
    required String conversationId,
    required String newPreview,
    required DateTime newDate,
  }) {
    _conversations = _conversations.map((conv) {
      if (conv.conversationId == conversationId) {
        return Conversation(
          conversationId: conv.conversationId,
          participantId: conv.participantId,
          participantName: conv.participantName,
          participantAvatar: conv.participantAvatar,
          lastMessagePreview: newPreview,
          lastMessageDate: newDate,
          unReadCount: conv.unReadCount,
        );
      }
      return conv;
    }).toList();
  }
}