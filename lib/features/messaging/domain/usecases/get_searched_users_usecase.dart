import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for searching users to message.
///
/// The intent of [GetSearchedUsersUsecase] is to find [PotentialConversation]
/// targets based on a search query through the [MessagingRepository].
class GetSearchedUsersUsecase {
  final MessagingRepository repo;
  GetSearchedUsersUsecase({required this.repo});

  Future<List<PotentialConversation>> call(String query) {
    return repo.getSearchedUsers(query);
  }
}
