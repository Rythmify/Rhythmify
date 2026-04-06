import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case to retrieve paginated and sorted root comments for a track.
class GetTrackCommentsUseCase {
  final CommentRepository _repository;

  GetTrackCommentsUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Delegates the sorting and pagination parameters to the backend via the repository.
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
