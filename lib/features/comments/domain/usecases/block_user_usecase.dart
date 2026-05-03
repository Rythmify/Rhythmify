import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to block a specific user.
///
/// This UseCase delegates the blocking action to the [CommentRepository].
class BlockUserUseCase {
  final CommentRepository _repository;

  /// Creates a [BlockUserUseCase] with the provided [_repository].
  BlockUserUseCase(this._repository);

  /// Executes the use case to block the user identified by [userId].
  ///
  /// Returns a [Future] that completes when the block operation succeeds,
  /// or throws an Exception via the repository on failure.
  Future<void> call(String userId) {
    return _repository.blockUser(userId);
  }
}
