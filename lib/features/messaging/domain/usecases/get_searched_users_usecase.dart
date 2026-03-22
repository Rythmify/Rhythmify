import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetSearchedUsersUsecase {
  final MessagingRepository repo;
  GetSearchedUsersUsecase({
    required this.repo
  });

  Future<List<PotentialConversation>> call(String query)
  {
    return repo.getSearchedUsers(query);
  }
}