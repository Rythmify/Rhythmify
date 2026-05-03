import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for marking a message as read.
///
/// The intent of [MarkMessagesAsReadUsecase] is to update the status of a specific message
/// within a conversation to 'read' via the [MessagingRepository].
class MarkMessagesAsReadUsecase {
  final MessagingRepository repo;

  MarkMessagesAsReadUsecase({required this.repo});

  Future<void> call(String messageId, String conversationId) {
    return repo.markMessageAsRead(messageId, conversationId);
  }
}
