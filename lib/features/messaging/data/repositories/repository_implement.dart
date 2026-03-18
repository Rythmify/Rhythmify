import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class RepositoryImplement implements MessagingRepository{
  final DatasourceInterface dataSource;

  RepositoryImplement({
    required this.dataSource
  });

  @override
  Future<List<Conversation>> getConversations(){
    return dataSource.getConversations();
  }

  @override
  Future<List<Message>> getMessages(String conversationId){
    return dataSource.getMessages(conversationId: conversationId);
  }

  @override
  Future<Conversation> startConversation(String participantId){
    return dataSource.newConversation(participantId: participantId);
  }

  @override
  Future<Message> sendMessage(String conversationId,String body){
    final requestContent=SentMessageRequestModel(body: body);
    return dataSource.sendMessage(conversationId: conversationId, requestContent: requestContent);
  }

  @override
  Future<void> blockUser(String participantId){
    return dataSource.blockUser(userId: participantId);
  }

  @override
  Future<void> unBlockUser(String participantId){
    return dataSource.unBlockUser(userId: participantId);
  }

  @override
  Future<void> markMessageAsRead(String messageId,String conversationId){
    return dataSource.markMessagesAsRead(conversationId: conversationId, messageId: messageId);
  }

  @override
  Future<int> getUnReadCount(){
    return dataSource.getUnreadCount();
  }
}