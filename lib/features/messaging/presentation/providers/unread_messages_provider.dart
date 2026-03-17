import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';

final unreadProvider=FutureProvider.family<List<Message>,String>((ref,conversationId) async{
  final messages=await ref.watch(messageProvider(conversationId).future);
  return messages.where((msg){
    return msg.senderId!='current_user'&&!msg.isRead;
  }).toList();
});