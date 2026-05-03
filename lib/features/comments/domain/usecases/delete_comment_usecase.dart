import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to permanently delete a comment.
///
/// This UseCase handles the business logic for deleting a comment via the [CommentRepository].
class DeleteCommentUseCase {
  final CommentRepository _repository;

  /// Creates a [DeleteCommentUseCase] with the provided [_repository].
  DeleteCommentUseCase(this._repository);

  /// Executes the use case to delete the comment identified by [commentId].
  ///
  /// Users can only delete comments that belong to them. The backend must
  /// verify the user's authorization token. Returns a [Future] that completes
  /// upon success, or throws an Exception via the repository on failure.
  Future<void> call(String commentId) {
    return _repository.deleteComment(commentId);
  }
}
