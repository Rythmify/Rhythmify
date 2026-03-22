import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class StartConversationUsecase {
  final MessagingRepository repo;

  StartConversationUsecase({
    required this.repo
  });

  Future<Conversation> call(String participantId,{String? body,String? trackId,String? playlistId})
  {
    return repo.startConversation(participantId,body,trackId,playlistId);
  }
}