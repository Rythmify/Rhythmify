import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving all conversations.
///
/// The intent of [GetConversationsUsecase] is to fetch the list of [Conversation]
/// summaries for the current user from the [MessagingRepository].
class GetConversationsUsecase {
  final MessagingRepository repo;

  GetConversationsUsecase({required this.repo});

  Future<List<Conversation>> call() {
    return repo.getConversations();
  }
}
