import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class UnblockUserUsecase {
  final MessagingRepository repo;

  UnblockUserUsecase({
    required this.repo
  });

  Future<void> call(String participantId)
  {
    return repo.unBlockUser(participantId);
  }
}