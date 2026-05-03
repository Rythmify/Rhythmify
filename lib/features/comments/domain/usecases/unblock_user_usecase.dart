import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to unblock a user.
///
/// This UseCase delegates the unblocking action to the [CommentRepository].
class UnblockUserUseCase {
  final CommentRepository _repository;

  /// Creates an [UnblockUserUseCase] with the provided [_repository].
  UnblockUserUseCase(this._repository);

  /// Executes the use case to unblock the user identified by [userId].
  ///
  /// Returns a [Future] that completes when the unblock operation succeeds,
  /// or throws an Exception via the repository on failure.
  Future<void> call(String userId) {
    return _repository.unblockUser(userId);
  }
}
