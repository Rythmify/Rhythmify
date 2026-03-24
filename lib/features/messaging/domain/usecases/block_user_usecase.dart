import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for blocking a user.
///
/// The intent of [BlockUserUsecase] is to prevent further communication
/// from a specific user by interacting with the [MessagingRepository].
class BlockUserUsecase {
  final MessagingRepository repo;

  BlockUserUsecase({required this.repo});

  Future<void> call(String participantId) {
    return repo.blockUser(participantId);
  }
}
