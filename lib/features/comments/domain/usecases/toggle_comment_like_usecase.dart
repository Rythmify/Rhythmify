import '../repositories/comment_repository.dart';

/// Use case to toggle the like state of a comment for the current user.
class ToggleCommentLikeUseCase {
  final CommentRepository _repository;

  ToggleCommentLikeUseCase(this._repository);

  /// Executes the use case.
  /// 
  /// Note: The UI layer (BLoC/Provider) should optimistically update the UI 
  /// before awaiting this network call to ensure the app feels responsive.
  Future<bool> call(String commentId) {
    return _repository.toggleCommentLike(commentId);
  }
}