import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Returns paginated replies to the specified top-level comment.
class GetRepliesUseCase {
  final CommentRepository _repository;

  /// Creates a [GetRepliesUseCase] with the provided [_repository].
  GetRepliesUseCase(this._repository);

  /// Executes the use case to fetch the replies.
  Future<List<Comment>> call({
    required String commentId,
    required int limit,
    required int offset,
  }) {
    return _repository.getReplies(
      commentId: commentId,
      limit: limit,
      offset: offset,
    );
  }
}
