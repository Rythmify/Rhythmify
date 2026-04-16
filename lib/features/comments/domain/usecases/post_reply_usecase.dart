import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Posts a reply to the specified top-level comment.
class PostReplyUseCase {
  final CommentRepository _repository;

  /// Creates a [PostReplyUseCase] with the provided [_repository].
  PostReplyUseCase(this._repository);

  /// Executes the use case to post the reply.
  Future<Comment> call({required String commentId, required String content}) {
    return _repository.postReply(commentId: commentId, content: content);
  }
}
