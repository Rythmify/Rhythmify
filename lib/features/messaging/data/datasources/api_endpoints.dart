class ApiEndPoints {
  ApiEndPoints._();

  static const String getConversations = '/messages/conversations';
  static String getConversation(String conversationId) =>
      '/messages/conversations/$conversationId';
  static String getMessages(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) =>
      '/messages/conversations/$conversationId/messages';
  static const String newConversation = '/messages/new';
  static const String getUnreadCount = '/messages/unread-count';
  static String blockUser(String userId) => '/messages/block/$userId';
  static String unBlockUser(String userId) => '/messages/block/$userId';
  static String markMessagesAsRead(String conversationId, String messageId) =>
      '/messages/conversations/$conversationId/messages/$messageId/read';
  static String getFollowings(String userId) => '/users/$userId/following';
  static String getSearchedUsers(String query) => '/search?q=$query&type=users';
}
