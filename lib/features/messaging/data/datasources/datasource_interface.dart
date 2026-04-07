import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/data/models/shared_embed_model.dart';

/// Interface defining the contract for messaging data sources.
///
/// This interface abstracts the underlying data provider (e.g., API, Local DB)
/// and specifies the methods required to perform messaging operations.
abstract class DatasourceInterface {
  /// Fetches the list of all conversations for the authenticated user.
  Future<List<ConversationModel>> getConversations();

  /// Fetches the list of messages for a given [conversationId].
  Future<List<MessageModel>> getMessages({required String conversationId});

  /// Sends a message within a specific [conversationId].
  Future<MessageModel> sendMessage({
    required String conversationId,
    required SentMessageRequestModel requestContent,
  });

  /// Initiates a new conversation with a participant.
  Future<ConversationModel> newConversation({
    required String participantId,
    String? body,
    String? trackId,
    String? playlistId,
  });

  /// Retrieves the total count of unread messages.
  Future<int> getUnreadCount();

  /// Blocks a user with the specified [userId].
  Future<void> blockUser({required String userId});

  /// Unblocks a user with the specified [userId].
  Future<void> unBlockUser({required String userId});

  /// Marks a specific [messageId] as read within a [conversationId].
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String messageId,
  });

  /// Retrieves the list of users followed by the current user.
  Future<List<PotentialConversationModel>> getFollowings(String myId);

  /// Searches for users based on a [query].
  Future<List<PotentialConversationModel>> getSearchedUsers(String query);

  /// Checks if the user with [participantId] is blocked by current user.
  Future<bool> isBlocked(String participantId);

  /// Checks if the user with [participantId] has blocked the current user.
  Future<bool> isBlockedBy(String participantId);

  /// Retrieves the list of liked embeds (tracks/playlists/Albums) for a user.
  Future<List<SharedEmbedModel>> getEmbeds(String userId, String embedType);

  /// Retrieves the details of a specific track by its [trackdId].
  Future<SharedEmbedModel> getTrackDetails(String trackId);

  /// Retrieves the details of a specific track by its [playlistId].
  Future<SharedEmbedModel> getPlaylistDetails(String playlistId, String embedType);

}
