import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to post a new comment or reply to a track.
///
/// This UseCase contains the business logic for creating a new comment via the [CommentRepository].
class PostCommentUseCase {
  final CommentRepository _repository;

  /// Creates a [PostCommentUseCase] with the provided [_repository].
  PostCommentUseCase(this._repository);

  /// Executes the use case to create the comment.
  ///
  /// Requires the [trackId] it belongs to, the text [content], and the [trackTimestamp].
  /// If [parentId] is null, it creates a root comment; if provided, it creates a reply.
  /// Returns a [Future] resolving to the newly created [Comment] entity.
  /// Throws an [ArgumentError] if the provided [content] is empty or just whitespace.
  Future<Comment> call({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  }) {
    if (content.trim().isEmpty) {
      throw ArgumentError('Comment content cannot be empty.');
    }

    return _repository.postComment(
      trackId: trackId,
      content: content,
      trackTimestamp: trackTimestamp,
      parentId: parentId,
    );
  }
}
