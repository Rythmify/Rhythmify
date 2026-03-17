import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class MarkMessagesAsReadUsecase {
  final MessagingRepository repo;

  MarkMessagesAsReadUsecase({
    required this.repo
  });

  Future<void> call(String messageId)
  {
    return repo.markMessageAsRead(messageId);
  }
}