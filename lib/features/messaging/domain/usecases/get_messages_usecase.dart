import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving messages in a conversation.
///
/// The intent of [GetMessagesUsecase] is to fetch the [Message] history
/// for a specific conversation ID from the [MessagingRepository].
class GetMessagesUsecase {
  final MessagingRepository repo;

  GetMessagesUsecase({required this.repo});

  Future<List<Message>> call(String conversationId) {
    return repo.getMessages(conversationId);
  }
}
