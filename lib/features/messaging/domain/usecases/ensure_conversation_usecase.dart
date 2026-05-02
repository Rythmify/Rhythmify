import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Ensures a conversation exists with [participantId] without sending a message.
///
/// Used when navigating directly to a chat screen — guarantees a conversation
/// record exists on the backend before any messages are loaded or sent.
/// If the conversation already exists, the server returns the existing one.
class EnsureConversationUsecase {
  final MessagingRepository repo;

  EnsureConversationUsecase({required this.repo});

  /// Returns the existing or newly created [Conversation] with [participantId].
  Future<Conversation> call(String participantId) {
    return repo.ensureConversation(participantId);
  }
}
