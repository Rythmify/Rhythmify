import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for sending a message in a conversation.
///
/// The intent of [SendMessageUsecase] is to deliver a new [Message] body
/// to an existing conversation through the [MessagingRepository].
class SendMessageUsecase {
  final MessagingRepository repo;

  SendMessageUsecase({required this.repo});

  Future<Message> call(String conversationId, String body) {
    return repo.sendMessage(conversationId, body);
  }
}
