import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class IsBlockedUsecase {
  final MessagingRepository repo;

  IsBlockedUsecase({required this.repo});

  Future<bool> call(String participantId) {
    return repo.isBlocked(participantId);
  }
}