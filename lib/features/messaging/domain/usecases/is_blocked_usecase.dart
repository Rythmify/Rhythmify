import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for checking if the current user has blocked [participantId].
///
/// Delegates to [MessagingRepository.isBlocked].
/// Used in [isBlockedProvider] to conditionally show [BlockedUserWidget].
class IsBlockedUsecase {
  final MessagingRepository repo;

  IsBlockedUsecase({required this.repo});

  Future<bool> call(String participantId) {
    return repo.isBlocked(participantId);
  }
}
