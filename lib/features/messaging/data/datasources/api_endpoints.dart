/// A utility class that defines all API endpoints for messaging-related operations.
///
/// This class provides constant strings and static methods to construct
/// the necessary URL paths for communication with the remote server.
class ApiEndPoints {
  ApiEndPoints._();

  /// Endpoint to retrieve all conversations for the current user.
  static const String getConversations = '/messages/conversations';

  /// Returns the endpoint to retrieve details for a specific [conversationId].
  static String getConversation(String conversationId) =>
      '/messages/conversations/$conversationId';

  /// Returns the endpoint to retrieve messages for a specific [conversationId].
  static String getMessages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';

  /// Returns the endpoint to send a message within a specific [conversationId].
  static String sendMessage(String conversationId) =>
      '/messages/conversations/$conversationId/messages';

  /// Endpoint to initiate a new conversation.
  static const String newConversation = '/messages/new';

  /// Endpoint to retrieve the total count of unread messages.
  static const String getUnreadCount = '/messages/unread-count';

  /// Returns the endpoint to block a specific user by their [userId].
  static String blockUser(String userId) => '/users/$userId/block';

  /// Returns the endpoint to unblock a specific user by their [userId].
  static String unBlockUser(String userId) => '/users/$userId/block';

  /// Returns the endpoint to mark a specific [messageId] as read in a [conversationId].
  static String markMessagesAsRead(String conversationId, String messageId) =>
      '/messages/conversations/$conversationId/messages/$messageId/read';

  /// Returns the endpoint to retrieve the list of users followed by [userId].
  static String getFollowings() => '/users/me/following';

  /// Returns the endpoint to search for users based on a [query].
  static String getSearchedUsers(String query) =>
      '/users/me/following?q=$query';

  /// Returns the endpoint to check if a user with [userId] is blocked by current user.
  static String isBlocked(String userId) => '/users/$userId/follow-status';

  /// Returns the endpoint to retrieve the details of a certain track using the [trackId]
  static String getTrackDetails(String trackId) => '/tracks/$trackId';

  /// Returns the endpoint to retrieve the details of a certain playlist using the [playlistId]
  static String getPlaylistDetails(String playlistId) =>
      '/playlists/$playlistId';

  /// Returns the endpoint to retrieve the tracks that the current user liked
  static String getMyLikedTracks() => '/me/liked-tracks';

  /// Returns the endpoint to retrieve the playlists that the current user liked
  static String getMyLikedPlaylists() => '/me/liked-playlists';

  /// Returns the endpoint to retrieve the albums that the current user liked
  static String getMyLikedAlbums() => '/me/liked-albums';
}
