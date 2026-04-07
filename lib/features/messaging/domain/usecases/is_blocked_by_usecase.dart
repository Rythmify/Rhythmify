import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for checking if the current user has been blocked by [participantId].
///
/// Delegates to [MessagingRepository.isBlockedBy].
/// Used in [isBlockedByProvider] to conditionally show [BlockedByWidget].
class IsBlockedByUsecase {
  final MessagingRepository repo;

  IsBlockedByUsecase({required this.repo});

  Future<bool> call(String participantId) {
    return repo.isBlockedBy(participantId);
  }
}
