import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRemoteRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  CommentRemoteRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Comment>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required CommentSortType sortType,
  }) async {
    try {
      final dtos = await _remoteDataSource.getTrackComments(
        trackId: trackId,
        page: page,
        limit: limit,
        sortValue: sortType.apiValue,
      );
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to fetch track comments: $e');
    }
  }

  @override
  Future<List<Comment>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required CommentSortType sortType,
  }) async {
    try {
      final dtos = await _remoteDataSource.getCommentReplies(
        commentId: commentId,
        page: page,
        limit: limit,
        sortValue: sortType.apiValue,
      );
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to fetch replies: $e');
    }
  }

  @override
  Future<Map<int, String>> getFloatingComments(String trackId) async {
    try {
      final allTrackComments = await _remoteDataSource.getAllCommentsForTrack(
        trackId,
      );
      final Map<int, String> floatingMap = {};

      for (var dto in allTrackComments) {
        // Skip if there's no profile picture to display
        if (dto.userPfp == null || dto.userPfp!.isEmpty) continue;

        // Group comments by the exact second to build the O(1) lookup map
        final second = dto.timestamp;

        // We only take the first comment's PFP for a given second to avoid overlap
        if (!floatingMap.containsKey(second)) {
          floatingMap[second] = dto.userPfp!;
        }
      }

      return floatingMap;
    } catch (e) {
      throw Exception('Failed to build floating comments map: $e');
    }
  }

  @override
  Future<Comment> postComment({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  }) async {
    try {
      final insertedDto = await _remoteDataSource.postComment(
        trackId: trackId,
        content: content,
        trackTimestamp: trackTimestamp,
        parentId: parentId,
      );
      return insertedDto.toDomain();
    } catch (e) {
      throw Exception('Failed to post comment: $e');
    }
  }

  @override
  Future<bool> toggleCommentLike(
    String commentId, {
    required bool isCurrentlyLiked,
  }) async {
    try {
      if (isCurrentlyLiked) {
        await _remoteDataSource.unlikeComment(commentId);
        return false; // Successfully unliked, return new state
      } else {
        await _remoteDataSource.likeComment(commentId);
        return true; // Successfully liked, return new state
      }
    } catch (e) {
      throw Exception('Failed to toggle like status: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _remoteDataSource.deleteComment(commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      await _remoteDataSource.blockUser(userId);
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      await _remoteDataSource.unblockUser(userId);
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }
}
