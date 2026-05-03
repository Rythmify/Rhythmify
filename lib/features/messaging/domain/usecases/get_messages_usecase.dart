import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving messages in a conversation.
///
/// The intent of [GetMessagesUsecase] is to fetch the [Message] history
/// for a specific conversation ID from the [MessagingRepository].
class GetMessagesUsecase {
  final MessagingRepository repo;

  GetMessagesUsecase({required this.repo});

  /// Fetches a page of [Message]s for [conversationId] at [offset].
  ///
  /// Returns a tuple of the message list and the total message count.
  Future<(List<Message>, int)> call(String conversationId, {int offset = 0}) {
    return repo.getMessages(conversationId, offset: offset);
  }
}
