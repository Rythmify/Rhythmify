import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

abstract class DatasourceInterface {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages({ required String conversationId });
  Future<MessageModel> sendMessage({required String conversationId,required SentMessageRequestModel requestContent});
  Future<ConversationModel> newConversation({required String participantId});
  Future<int> getUnreadCount();
  Future<void> blockUser({required String userId});
  Future<void> unBlockUser({required String userId});
  Future<void> markMessagesAsRead({required String conversationId,required String messageId});
  Future<List<PotentialConversationModel>> getFollowings(String myId);
  Future<List<PotentialConversationModel>> getSearchedUsers(String query);
}