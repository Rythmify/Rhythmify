import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for getting the total unread message count.
///
/// The intent of [GetUnreadCountUsecase] is to retrieve the overall count
/// of unread messages for the user from the [MessagingRepository].
class GetUnreadCountUsecase {
  final MessagingRepository repo;

  GetUnreadCountUsecase({required this.repo});

  Future<int> call() {
    return repo.getUnReadCount();
  }
}
