
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations();
  Future<List<Message>> getMessages(String conversationId);
  Future<Conversation> startConversation(String participantId);
  Future<Message> sendMessage(String conversationId,String body);
  Future<void> blockUser(String participantId);
  Future<void> unBlockUser(String participantId);
  Future<void> markMessageAsRead(String messageId,String conversationId);
  Future<int> getUnReadCount();
}