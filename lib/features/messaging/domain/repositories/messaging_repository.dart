import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

/// Abstract repository defining the contract for messaging-related operations.
///
/// This layer serves as a bridge between the [Domain] layer and the [Data] layer,
/// defining how the application interacts with messaging data.
abstract class MessagingRepository {
  /// Retrieves a list of all active [Conversation]s for the current user.
  Future<List<Conversation>> getConversations();

  /// Retrieves the history of [Message]s for a specific [conversationId].
  Future<List<Message>> getMessages(String conversationId);

  /// Initiates a new [Conversation] with a specific participant.
  ///
  /// Can optionally include an initial message body or a shared track/playlist.
  Future<Conversation> startConversation(
    String participantId,
    String? body,
    String? trackId,
    String? playlistId,
  );

  /// Sends a new [Message] within an existing conversation.
  Future<Message> sendMessage(String conversationId, String body);

  /// Blocks a user by their [participantId], preventing further communication.
  Future<void> blockUser(String participantId);

  /// Unblocks a previously blocked user by their [participantId].
  Future<void> unBlockUser(String participantId);

  /// Marks a specific [Message] as read within a given [conversationId].
  Future<void> markMessageAsRead(String messageId, String conversationId);

  /// Retrieves the total count of unread messages across all conversations.
  Future<int> getUnReadCount();

  /// Retrieves a list of [PotentialConversation]s from the user's following list.
  Future<List<PotentialConversation>> getFollowings(String userId);

  /// Searches for [PotentialConversation]s based on a search [query].
  Future<List<PotentialConversation>> getSearchedUsers(String query);

  ///Checks if the user with [participantId] is blocked by current user.
  Future<bool> isBlocked(String participantId);

  ///Checks if the user with [participantId] has blocked the current user.
  Future<bool> isBlockedBy(String participantId);
}
