import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class BlockUserUsecase {
  final MessagingRepository repo;

  BlockUserUsecase({required this.repo});

  Future<void> call(String participantId) {
    return repo.blockUser(participantId);
  }
}
