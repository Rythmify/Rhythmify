import '../entities/comment.dart';

/// Defines the available sorting strategies for fetching comments.
enum CommentSortType { newest, oldest, trackTime }

extension CommentSortTypeExtension on CommentSortType {
  /// Converts the enum to the string format expected by the backend API.
  String get apiValue {
    switch (this) {
      case CommentSortType.newest:
        return 'newest';
      case CommentSortType.oldest:
        return 'oldest';
      case CommentSortType.trackTime:
        return 'trackTime';
    }
  }
}

/// Abstract contract for the Comment Data layer.
///
/// This repository handles fetching, posting, liking, and deleting comments.
/// Any concrete implementation (e.g., `CommentApiRepositoryImpl`) must fulfill this contract.
abstract class CommentRepository {
  /// Fetches a paginated list of root comments for a specific track.
  ///
  /// [trackId] The unique identifier of the track.
  /// [page] The current page number for pagination (starts at 1).
  /// [limit] The number of comments to fetch per page.
  /// [sortType] The sorting strategy applied by the backend database.
  Future<List<Comment>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required CommentSortType sortType,
  });

  /// Fetches a paginated list of replies for a specific parent comment.
  ///
  /// [commentId] The unique identifier of the parent comment.
  /// [page] The current page number for pagination.
  /// [limit] The number of replies to fetch per page.
  /// [sortType] The sorting strategy applied by the backend.
  Future<List<Comment>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required CommentSortType sortType,
  });

  /// Fetches a lightweight mapping of floating comments for the audio waveform.
  ///
  /// Returns a Map where the Key is the timestamp in seconds,
  /// and the Value is the URL of the user's profile picture.
  /// This is highly optimized for O(1) lookups during audio playback.
  Future<Map<int, ({String? pfp, String text})>> getFloatingComments(
    String trackId,
  );

  /// Posts a new comment or a reply to an existing comment.
  ///
  /// [trackId] The track this comment belongs to.
  /// [content] The text content of the comment.
  /// [trackTimestamp] The exact millisecond in the track where the comment was made.
  /// [parentId] Optional. If provided, this comment becomes a reply to the parent.
  Future<Comment> postComment({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  });

  /// Toggles the like status of a specific comment for the current user.
  ///
  /// [commentId] The unique identifier of the comment.
  /// [isCurrentlyLiked] The current state of the like to determine the API route.
  /// Returns `true` if the comment is now liked, `false` if unliked.
  Future<bool> toggleCommentLike(
    String commentId, {
    required bool isCurrentlyLiked,
  });

  /// Deletes a specific comment owned by the current user.
  Future<void> deleteComment(String commentId);

  /// Blocks a user.
  Future<void> blockUser(String userId);

  /// Unblocks a user.
  Future<void> unblockUser(String userId);
}
