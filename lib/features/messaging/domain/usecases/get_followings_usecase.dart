import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetFollowingsUsecase {
  final MessagingRepository repo;

  GetFollowingsUsecase({required this.repo});

  Future<List<PotentialConversation>> call(String myId) {
    return repo.getFollowings(myId);
  }
}
