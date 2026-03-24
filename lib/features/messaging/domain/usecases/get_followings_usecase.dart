import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving followed users.
///
/// The intent of [GetFollowingsUsecase] is to provide a list of [PotentialConversation]
/// candidates based on who the current user follows, via the [MessagingRepository].
class GetFollowingsUsecase {
  final MessagingRepository repo;

  GetFollowingsUsecase({required this.repo});

  Future<List<PotentialConversation>> call(String myId) {
    return repo.getFollowings(myId);
  }
}
