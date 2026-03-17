import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.conversationId,
    required super.participantId,
    required super.participantName,
    super.participantAvatar,
    super.lastMessagePreview,
    super.lastMessageDate,
    required super.unReadCount
  });

  factory ConversationModel.fromJson(Map<String,dynamic> json)
  {
    return ConversationModel(conversationId: json['id'],
    participantId: json['participant']['id'],
    participantName: json['participant']['display_name'],
    participantAvatar: json['participant']?['profile_picture'],
    lastMessagePreview: json['last_message']?['body'],
    lastMessageDate: json['last_message']!=null?
      DateTime.parse(json['last_message']['created_at'])
      :null,
    unReadCount: json['unread_count']);
  }

  Map<String,dynamic> toJson()
  {
    return{
      'id':conversationId,
      'participant':{
        'id':participantId,
        'display_name':participantName,
        'profile_picture':participantAvatar
      },
      'last_message': lastMessagePreview!=null?
      {
        'body':lastMessagePreview,
        'created_at':lastMessageDate?.toIso8601String()
      }
      :null,
      'unread_count':unReadCount
    };
  }
}