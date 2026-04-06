import '../repositories/comment_repository.dart';

/// Use case to toggle the like state of a comment for the current user.
class ToggleCommentLikeUseCase {
  final CommentRepository _repository;

  ToggleCommentLikeUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Note: The UI layer (BLoC/Provider) should optimistically update the UI
  /// before awaiting this network call to ensure the app feels responsive.
  ///
  /// [commentId] The ID of the comment to like/unlike.
  /// [isCurrentlyLiked] The current like state of the comment in the UI.
  Future<bool> call(String commentId, {required bool isCurrentlyLiked}) {
    return _repository.toggleCommentLike(
      commentId,
      isCurrentlyLiked: isCurrentlyLiked,
    );
  }
}
