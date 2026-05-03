import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for starting a new conversation.
///
/// The intent of [StartConversationUsecase] is to initiate a new [Conversation]
/// with a participant, optionally including an initial message or shared content
/// (track or playlist), via the [MessagingRepository].
class StartConversationUsecase {
  final MessagingRepository repo;

  StartConversationUsecase({required this.repo});

  Future<Conversation> call(
    String participantId, {
    String? body,
    String? trackId,
    String? playlistId,
  }) {
    return repo.startConversation(participantId, body, trackId, playlistId);
  }
}
