import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

/// Concrete implementation of the [CommentRepository] communicating with the remote API.
///
/// This repository relies on [CommentRemoteDataSource] to fetch and mutate
/// data from the network, and maps raw [CommentDto] objects into Domain layer [Comment] entities.
/// Rethrows caught exceptions for the presentation layer to handle.
class CommentRemoteRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  /// Creates a [CommentRemoteRepositoryImpl] with the provided [_remoteDataSource].
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
  Future<List<Comment>> getReplies({
    required String commentId,
    required int limit,
    required int offset,
  }) async {
    try {
      final dtos = await _remoteDataSource.getReplies(
        commentId: commentId,
        limit: limit,
        offset: offset,
      );
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to fetch replies: $e');
    }
  }

  @override
  Future<Map<int, ({String? pfp, String text})>> getFloatingComments(
    String trackId,
  ) async {
    try {
      final allTrackComments = await _remoteDataSource.getAllCommentsForTrack(
        trackId,
      );

      final Map<int, ({String? pfp, String text})> floatingMap = {};

      for (var dto in allTrackComments) {
        final second = dto.timestamp;
        if (!floatingMap.containsKey(second)) {
          floatingMap[second] = (pfp: dto.userPfp, text: dto.content);
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
  Future<Comment> postReply({
    required String commentId,
    required String content,
  }) async {
    try {
      final insertedDto = await _remoteDataSource.postReply(
        commentId: commentId,
        content: content,
      );
      return insertedDto.toDomain();
    } catch (e) {
      throw Exception('Failed to post reply: $e');
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
        return false;
      } else {
        await _remoteDataSource.likeComment(commentId);
        return true;
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
