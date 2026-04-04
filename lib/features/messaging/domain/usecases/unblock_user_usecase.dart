import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for unblocking a user.
///
/// The intent of [UnblockUserUsecase] is to restore the ability to communicate
/// with a previously blocked user by interacting with the [MessagingRepository].
class UnblockUserUsecase {
  final MessagingRepository repo;

  UnblockUserUsecase({required this.repo});

  Future<void> call(String participantId) {
    return repo.unBlockUser(participantId);
  }
}
