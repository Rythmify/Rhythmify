import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to retrieve paginated and sorted replies for a specific parent comment.
///
/// It coordinates fetching nested comments via the [CommentRepository].
class GetCommentRepliesUseCase {
  final CommentRepository _repository;

  /// Creates a [GetCommentRepliesUseCase] with the provided [_repository].
  GetCommentRepliesUseCase(this._repository);

  /// Executes the use case to fetch the replies.
  ///
  /// Requires the parent [commentId], the target [page], an optional [limit]
  /// (defaulting to 20), and a [sortType] strategy.
  /// Returns a [Future] resolving to a list of [Comment] entities, or throws an Exception on failure.
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
