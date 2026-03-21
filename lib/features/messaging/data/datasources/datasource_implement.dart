import 'package:dio/dio.dart';
import 'package:rythmify/features/messaging/data/datasources/api_endpoints.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_interface.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
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
  final List data = body['data']['items'];

  return data
      .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
      .toList();

}

  @override
  Future<List<MessageModel>> getMessages({required String conversationId}) async {
    final response = await dio.get(ApiEndPoints.getConversation(conversationId));

    print('type: ${response.data.runtimeType}');
    print('data: ${response.data}');

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
  Future<ConversationModel> newConversation({required String participantId,
    String? body,
    String? trackId,
    String? playlistId}) async{
    final response = await dio.post(
      ApiEndPoints.newConversation,
      data: {
        'recipient_id': participantId,
        if(body!=null)'body':body,
        if(trackId!=null) 'track_id':trackId,
        if(playlistId!=null) 'playlist_id':playlistId,
      },
    );
    return ConversationModel.fromJson(
      response.data['data']['conversation'] as Map<String,dynamic>
    );
  }

  @override
  Future<int> getUnreadCount() async{
    final response=await dio.get(ApiEndPoints.getUnreadCount);
    return response.data['data']['unread_count'] as int;
  }

  @override
  Future<void> blockUser({required String userId})async{
    await dio.delete(ApiEndPoints.blockUser(userId));
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

  @override
  Future<List<PotentialConversationModel>> getFollowings(String myId) async{
    final response=await dio.get(ApiEndPoints.getFollowings(myId));
    final body=response.data;
    final List data=body['data']['items'];
    return data
      .map((e)=>PotentialConversationModel.fromJson(e as Map<String,dynamic>))
      .toList();
  }

  @override
  Future<List<PotentialConversationModel>> getSearchedUsers(String query)async{
    final response=await dio.get(ApiEndPoints.getSearchedUsers(query));
    final body=response.data;
    final List data=body['data']['users'];
    return data
      .map((e)=>PotentialConversationModel.fromJson(e as Map<String,dynamic>))
      .toList();
  }
}