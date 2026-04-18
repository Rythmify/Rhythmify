import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to retrieve paginated and sorted root comments for a track.
///
/// It delegates the querying process to the [CommentRepository].
class GetTrackCommentsUseCase {
  final CommentRepository _repository;

  /// Creates a [GetTrackCommentsUseCase] with the provided [_repository].
  GetTrackCommentsUseCase(this._repository);

  /// Executes the use case to fetch comments.
  ///
  /// Requires the target [trackId], the [page] number, an optional [limit]
  /// (defaulting to 20), and an optional [sortType] for backend sorting.
  /// Returns a [Future] resolving to a list of root [Comment] entities, or throws an Exception.
  Future<List<Comment>> call({
    required String trackId,
    required int page,
    int limit = 20,
    CommentSortType sortType = CommentSortType.newest,
  }) {
    return _repository.getTrackComments(
      trackId: trackId,
      page: page,
      limit: limit,
      sortType: sortType,
    );
  }
}
