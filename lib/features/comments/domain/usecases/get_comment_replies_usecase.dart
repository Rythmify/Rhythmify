import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case to retrieve paginated and sorted replies for a specific parent comment.
class GetCommentRepliesUseCase {
  final CommentRepository _repository;

  GetCommentRepliesUseCase(this._repository);

  /// Executes the use case.
  Future<List<Comment>> call({
    required String commentId,
    required int page,
    int limit = 20,
    CommentSortType sortType = CommentSortType.newest,
  }) {
    return _repository.getCommentReplies(
      commentId: commentId,
      page: page,
      limit: limit,
      sortType: sortType,
    );
  }
}
