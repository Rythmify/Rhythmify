import '../repositories/comment_repository.dart';

/// Use case to unblock a user.
class UnblockUserUseCase {
  final CommentRepository _repository;

  UnblockUserUseCase(this._repository);

  /// Executes the use case.
  Future<void> call(String userId) {
    return _repository.unblockUser(userId);
  }
}
