import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetUnreadCountUsecase {
  final MessagingRepository repo;

  GetUnreadCountUsecase({
    required this.repo
  });

  Future<int> call()
  {
    return repo.getUnReadCount();
  }
}