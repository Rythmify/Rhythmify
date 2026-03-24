import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Concrete implementation of [MessagingRepository] that coordinates data access.
///
/// This repository acts as a mediator between the domain layer and the 
/// [DatasourceInterface], handling data transformation and business logic delegation.
class RepositoryImplement implements MessagingRepository {
  /// The data source used to fetch and persist messaging data.
  final DatasourceInterface dataSource;

  RepositoryImplement({required this.dataSource});

  @override
  Future<List<Conversation>> getConversations() {
    return dataSource.getConversations();
  }

  @override
  Future<List<Message>> getMessages(String conversationId) {
    return dataSource.getMessages(conversationId: conversationId);
  }

  @override
  Future<Conversation> startConversation(
    String participantId,
    String? body,
    String? trackId,
    String? playlistId,
  ) {
    return dataSource.newConversation(
      participantId: participantId,
      body: body,
      trackId: trackId,
      playlistId: playlistId,
    );
  }

  @override
  Future<Message> sendMessage(String conversationId, String body) {
    final requestContent = SentMessageRequestModel(body: body);
    return dataSource.sendMessage(
      conversationId: conversationId,
      requestContent: requestContent,
    );
  }

  @override
  Future<void> blockUser(String participantId) {
    return dataSource.blockUser(userId: participantId);
  }

  @override
  Future<void> unBlockUser(String participantId) {
    return dataSource.unBlockUser(userId: participantId);
  }

  @override
  Future<void> markMessageAsRead(String messageId, String conversationId) {
    return dataSource.markMessagesAsRead(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  @override
  Future<int> getUnReadCount() {
    return dataSource.getUnreadCount();
  }

  @override
  Future<List<PotentialConversation>> getFollowings(String myId) {
    return dataSource.getFollowings(myId);
  }

  @override
  Future<List<PotentialConversation>> getSearchedUsers(String query) {
    return dataSource.getSearchedUsers(query);
  }
}
