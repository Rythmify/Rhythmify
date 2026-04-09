import '../repositories/comment_repository.dart';

/// Use case to block a user.
class BlockUserUseCase {
  final CommentRepository _repository;

  BlockUserUseCase(this._repository);

  /// Executes the use case.
  Future<void> call(String userId) {
    return _repository.blockUser(userId);
  }
}
