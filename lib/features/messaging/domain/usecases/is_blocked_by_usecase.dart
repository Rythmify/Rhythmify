import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class IsBlockedByUsecase {
  final MessagingRepository repo;

  IsBlockedByUsecase({required this.repo});

  Future<bool> call(String participantId) {
    return repo.isBlockedBy(participantId);
  }
}