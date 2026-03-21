import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/start_conversation_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

class SendMessageNotifier extends StateNotifier<bool> {
  final Ref ref;

  SendMessageNotifier({
    required this.ref
  }):super(false);

  Future<void> sendMessage({
    required String body,
    String? conversationId,
    String? newParticipantId,
    String? embedId,
    String? embedType
  }) async{
    state=true;
    if(conversationId!=null)
    {
      final uCase=SendMessageUsecase(repo: ref.read(repositoryprovider));
      await(uCase(conversationId,body));
      ref.invalidate(conversationProvider);
      ref.invalidate(messageProvider(conversationId));
      state=false;
    }
    else
    {
      final uCase=StartConversationUsecase(repo: ref.read(repositoryprovider));
      await(uCase(newParticipantId!,
      body: body,
      trackId: embedType=='track'?embedId:null,
      playlistId: embedType=='playlist'?embedId:null,
      ));
      ref.invalidate(conversationProvider);
    }
    
  }

}