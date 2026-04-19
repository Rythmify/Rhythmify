import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class EnsureConversationUsecase {
  final MessagingRepository repo;

  EnsureConversationUsecase({required this.repo});

  Future<Conversation> call(String participantId) {
    return repo.ensureConversation(participantId);
  }
}
