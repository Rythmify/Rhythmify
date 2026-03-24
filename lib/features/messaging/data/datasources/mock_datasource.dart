import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

/// Mock implementation of [DatasourceInterface] for testing and development.
///
/// This class provides simulated messaging data and delayed responses to mimic 
/// network latency without making actual API calls.
class MockDatasourceImplement implements DatasourceInterface {
  /// Internal storage for simulated users.
  final Map<String, PotentialConversationModel> _allUsers = {
    'u2': PotentialConversationModel(
      participantId: 'u2',
      participantName: 'Ali',
      followersCount: 120,
      avatar: null,
      location: 'Cairo',
    ),
    'u3': PotentialConversationModel(
      participantId: 'u3',
      participantName: 'Mona',
      followersCount: 340,
      avatar: null,
      location: 'Alexandria',
    ),
    'u4': PotentialConversationModel(
      participantId: 'u4',
      participantName: 'Omar',
      followersCount: 320,
      avatar: null,
      location: null,
    ),
    'u5': PotentialConversationModel(
      participantId: 'u5',
      participantName: 'Layla',
      followersCount: 870,
      avatar: null,
      location: null,
    ),
    'u6': PotentialConversationModel(
      participantId: 'u6',
      participantName: 'Karim',
      followersCount: 150,
      avatar: null,
      location: null,
    ),
    'u7': PotentialConversationModel(
      participantId: 'u7',
      participantName: 'Sara',
      followersCount: 500,
      avatar: null,
      location: 'Giza',
    ),
    'u8': PotentialConversationModel(
      participantId: 'u8',
      participantName: 'Nour',
      followersCount: 200,
      avatar: null,
      location: null,
    ),
  };

  /// Simulated IDs of users followed by the current user.
  final List<String> _followingIds = ['u2', 'u3', 'u4', 'u5', 'u6'];

  /// Internal storage for simulated conversations.
  late final List<ConversationModel> _conversations = [
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

  /// Internal storage for simulated messages indexed by conversation ID.
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
  Future<List<MessageModel>> getMessages({
    required String conversationId,
  }) async {
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
      embedType: requestContent.trackId != null
          ? 'track'
          : requestContent.playlistId != null
          ? 'playlist'
          : null,
      embedId: requestContent.trackId ?? requestContent.playlistId,
      isRead: true,
      createdAt: DateTime.now(),
    );

    final oldList = _messagesByConversation[conversationId] ?? [];
    _messagesByConversation[conversationId] = [...oldList, newMessage];

    final index = _conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = ConversationModel(
        conversationId: old.conversationId,
        participantId: old.participantId,
        participantName: old.participantName,
        participantAvatar: old.participantAvatar,
        lastMessagePreview: newMessage.body ?? '',
        lastMessageDate: newMessage.createdAt,
        unReadCount: old.unReadCount,
      );
    }

    return newMessage;
  }

  @override
  Future<ConversationModel> newConversation({
    required String participantId,
    String? body,
    String? trackId,
    String? playlistId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if conversation already exists with this participant
    final existingIndex = _conversations.indexWhere(
      (c) => c.participantId == participantId,
    );
    if (existingIndex != -1) {
      final conv = _conversations[existingIndex];
      if (body != null) {
        final newMessage = MessageModel(
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conv.conversationId,
          senderId: 'current_user',
          body: body,
          embedType: trackId != null
              ? 'track'
              : playlistId != null
              ? 'playlist'
              : null,
          embedId: trackId ?? playlistId,
          isRead: true,
          createdAt: DateTime.now(),
        );
        final oldList = _messagesByConversation[conv.conversationId] ?? [];
        _messagesByConversation[conv.conversationId] = [...oldList, newMessage];
        _conversations[existingIndex] = ConversationModel(
          conversationId: conv.conversationId,
          participantId: conv.participantId,
          participantName: conv.participantName,
          participantAvatar: conv.participantAvatar,
          lastMessagePreview: body,
          lastMessageDate: DateTime.now(),
          unReadCount: conv.unReadCount,
        );
      }
      return _conversations[existingIndex];
    }

    // Get participant name from known users
    final user = _allUsers[participantId];
    final participantName = user?.participantName ?? 'Unknown User';

    final newConvId = 'c${DateTime.now().millisecondsSinceEpoch}';
    final newConv = ConversationModel(
      conversationId: newConvId,
      participantId: participantId,
      participantName: participantName,
      participantAvatar: null,
      lastMessagePreview: body ?? '',
      lastMessageDate: DateTime.now(),
      unReadCount: 0,
    );

    _conversations.insert(0, newConv);

    _messagesByConversation[newConvId] = body != null
        ? [
            MessageModel(
              messageId: DateTime.now().millisecondsSinceEpoch.toString(),
              conversationId: newConvId,
              senderId: 'current_user',
              body: body,
              embedType: trackId != null
                  ? 'track'
                  : playlistId != null
                  ? 'playlist'
                  : null,
              embedId: trackId ?? playlistId,
              isRead: true,
              createdAt: DateTime.now(),
            ),
          ]
        : [];

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

    final index = _conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
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

  @override
  Future<List<PotentialConversationModel>> getFollowings(String myId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _followingIds.map((id) => _allUsers[id]!).toList();
  }

  @override
  Future<List<PotentialConversationModel>> getSearchedUsers(
    String query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.trim().isEmpty) return [];
    return _allUsers.values
        .where(
          (u) => u.participantName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
