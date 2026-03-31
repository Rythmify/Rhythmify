import '../repositories/comment_repository.dart';

/// Use case to permanently delete a comment.
class DeleteCommentUseCase {
  final CommentRepository _repository;

  DeleteCommentUseCase(this._repository);

  /// Executes the use case.
  /// 
  /// Users can only delete comments that belong to them. 
  /// Backend must verify the user's authorization token.
  Future<void> call(String commentId) {
    return _repository.deleteComment(commentId);
  }
}