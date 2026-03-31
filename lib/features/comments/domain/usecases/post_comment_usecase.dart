import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case to post a new comment or reply to a track.
class PostCommentUseCase {
  final CommentRepository _repository;

  PostCommentUseCase(this._repository);

  /// Executes the use case.
  /// 
  /// If [parentId] is null, it creates a root comment. 
  /// If [parentId] is provided, it creates a reply.
  Future<Comment> call({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  }) {
    // Optional: Add domain-level validation here (e.g., throw error if content is empty)
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