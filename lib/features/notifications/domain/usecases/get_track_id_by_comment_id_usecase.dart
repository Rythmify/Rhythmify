import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Returns the `track_id` for the comment identified by [commentId].
///
/// Used by [trackByCommentIdProvider] to resolve the track for comment-type
/// notification tiles.
class GetTrackIdByCommentIdUsecase {
  final NotificationsRepoInterface repo;
  GetTrackIdByCommentIdUsecase(this.repo);

  Future<({String? trackId, bool isLikedByMe})> call(String commentId) => repo.getTrackIdByCommentId(commentId);
}