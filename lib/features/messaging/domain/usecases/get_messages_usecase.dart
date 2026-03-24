import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetMessagesUsecase {
  final MessagingRepository repo;

  GetMessagesUsecase({required this.repo});

  Future<List<Message>> call(String conversationId) {
    return repo.getMessages(conversationId);
  }
}
