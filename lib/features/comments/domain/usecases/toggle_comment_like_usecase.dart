import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to toggle the like state of a comment for the current user.
///
/// This UseCase delegates the mutation action to the [CommentRepository].
class ToggleCommentLikeUseCase {
  final CommentRepository _repository;

  /// Creates a [ToggleCommentLikeUseCase] with the provided [_repository].
  ToggleCommentLikeUseCase(this._repository);

  /// Executes the use case to toggle the like status.
  ///
  /// Requires the target [commentId] and the [isCurrentlyLiked] state representing
  /// the current status in the UI to determine the proper API action (like/unlike).
  /// Note: The Presentation layer should optimistically update the UI before
  /// awaiting this network call to ensure responsiveness.
  /// Returns a [Future] resolving to a boolean indicating the new like status.
  Future<bool> call(String commentId, {required bool isCurrentlyLiked}) {
    return _repository.toggleCommentLike(
      commentId,
      isCurrentlyLiked: isCurrentlyLiked,
    );
  }
}
