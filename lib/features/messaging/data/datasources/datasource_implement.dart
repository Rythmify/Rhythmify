import 'package:dio/dio.dart';
import 'package:rythmify/features/messaging/data/datasources/api_endpoints.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

class DatasourceImplement implements DatasourceInterface{
  final Dio dio;
  DatasourceImplement({
    required this.dio
  });

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await dio.get(ApiEndPoints.getConversations);
    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

  final body = response.data as Map<String, dynamic>;
  final List data = body['data'];

  return data
      .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

  @override
  Future<List<MessageModel>> getMessages({required String conversationId}) async {
    final response = await dio.get(ApiEndPoints.getMessages(conversationId));
    if (response.data is! Map<String, dynamic>) {
      throw Exception(
        'Expected JSON map but got ${response.data.runtimeType}: ${response.data}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final List data = body['data']['messages'];

    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage({required String conversationId,required SentMessageRequestModel requestContent})async{
    final response = await dio.post(ApiEndPoints.sendMessage(conversationId),data:requestContent.toJson());
    return MessageModel.fromJson(
      response.data['data'] as Map<String,dynamic>
    );

  }

  @override
  Future<ConversationModel> newConversation({required String participantId}) async{
    final response = await dio.post(
      ApiEndPoints.newConversation,
      data: {
        'participant_id': participantId,
      },
    );
    return ConversationModel.fromJson(
      response.data['data'] as Map<String,dynamic>
    );
  }

  @override
  Future<int> getUnreadCount() async{
    final response=await dio.get(ApiEndPoints.getUnreadCount);
    return int.tryParse(response.data['data'].toString()) ?? 0;
  }

  @override
  Future<void> blockUser({required String userId})async{
    await dio.post(ApiEndPoints.blockUser(userId));
  }

  @override
  Future<void> unBlockUser({required String userId})async{
    await dio.post(ApiEndPoints.unBlockUser(userId));
  }

  @override
  Future<void> markMessagesAsRead({required String conversationId,required String messageId})async{
    await dio.patch(ApiEndPoints.markMessagesAsRead(conversationId, messageId),
    data: {
      'is_read':true,
    }
    );
  }
}