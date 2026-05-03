import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
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
  /// Fetches all active conversations for the current user.
  Future<List<Conversation>> getConversations() {
    return dataSource.getConversations();
  }

  @override
  /// Fetches a paginated page of messages for [conversationId] starting at [offset].
  ///
  /// Returns a tuple of the message list and the total message count.
  Future<(List<Message>, int)> getMessages(
    String conversationId, {
    int offset = 0,
  }) {
    return dataSource.getMessages(
      conversationId: conversationId,
      offset: offset,
    );
  }

  @override
  /// Starts a new conversation with [participantId].
  ///
  /// Passes an optional [body] text and/or a [trackId] or [playlistId] embed.
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
  /// Sends a message within an existing [conversationId].
  ///
  /// Builds a [SentMessageRequestModel] from the provided fields before
  /// delegating to the datasource.
  Future<Message> sendMessage(
    String conversationId,
    String? body,
    String? embedId,
    String? embedType,
  ) {
    final requestContent = SentMessageRequestModel(
      body: body,
      embedId: embedId,
      embedType: embedType,
    );
    return dataSource.sendMessage(
      conversationId: conversationId,
      requestContent: requestContent,
    );
  }

  @override
  /// Blocks the user identified by [participantId].
  Future<void> blockUser(String participantId) {
    return dataSource.blockUser(userId: participantId);
  }

  @override
  /// Unblocks the user identified by [participantId].
  Future<void> unBlockUser(String participantId) {
    return dataSource.unBlockUser(userId: participantId);
  }

  @override
  /// Marks [messageId] as read within [conversationId].
  Future<void> markMessageAsRead(String messageId, String conversationId) {
    return dataSource.markMessagesAsRead(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  @override
  /// Returns the total count of unread messages across all conversations.
  Future<int> getUnReadCount() {
    return dataSource.getUnreadCount();
  }

  @override
  /// Returns the list of users followed by the current user ([myId]).
  Future<List<PotentialConversation>> getFollowings(String myId) {
    return dataSource.getFollowings(myId);
  }

  @override
  /// Searches for users matching [query].
  Future<List<PotentialConversation>> getSearchedUsers(String query) {
    return dataSource.getSearchedUsers(query);
  }

  @override
  /// Returns `true` if the current user has blocked [participantId].
  Future<bool> isBlocked(String participantId) {
    return dataSource.isBlocked(participantId);
  }

  @override
  /// Returns `true` if [participantId] has blocked the current user.
  Future<bool> isBlockedBy(String participantId) {
    return dataSource.isBlockedBy(participantId);
  }

  @override
  /// Returns the current user's liked embeds filtered by [embedType].
  ///
  /// [embedType] is one of `track`, `playlist`, or `album`.
  Future<List<SharedEmbed>> getLikedEmbeds(String userId, String embedType) {
    return dataSource.getEmbeds(userId, embedType);
  }

  @override
  /// Returns track metadata for [trackId] as a [SharedEmbed].
  Future<SharedEmbed> getTrack(String trackId) {
    return dataSource.getTrackDetails(trackId);
  }

  @override
  /// Returns playlist or album metadata for [playlistId] as a [SharedEmbed].
  ///
  /// [embedType] distinguishes between `playlist` and `album`.
  Future<SharedEmbed> getPlaylist(String playlistId, String embedType) {
    return dataSource.getPlaylistDetails(playlistId, embedType);
  }

  @override
  /// Ensures a conversation with [participantId] exists, creating one if needed.
  Future<Conversation> ensureConversation(String participantId) {
    return dataSource.ensureConversation(participantId: participantId);
  }
}
