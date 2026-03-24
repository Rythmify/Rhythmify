import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class SendMessageUsecase {
  final MessagingRepository repo;

  SendMessageUsecase({required this.repo});

  Future<Message> call(String conversationId, String body) {
    return repo.sendMessage(conversationId, body);
  }
}
