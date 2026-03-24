import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetConversationsUsecase {
  final MessagingRepository repo;

  GetConversationsUsecase({required this.repo});

  Future<List<Conversation>> call() {
    return repo.getConversations();
  }
}
