import 'package:uuid/uuid.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_local_datasource.dart';
import '../../data/models/comment_dto.dart';

/// Concrete mock implementation of the [CommentRepository].
///
/// This implementation relies on the [CommentLocalDataSource] to simulate
/// network requests locally without contacting a backend server.
/// It gracefully maps raw [CommentDto] objects to Domain [Comment] entities.
class MockCommentRepositoryImpl implements CommentRepository {
  final CommentLocalDataSource _localDataSource;

  /// Creates a [MockCommentRepositoryImpl] with the provided [_localDataSource].
  MockCommentRepositoryImpl(this._localDataSource);

  @override
  Future<List<Comment>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required CommentSortType sortType,
  }) async {
    try {
      final dtos = await _localDataSource.getTrackComments(
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
      final dtos = await _localDataSource.getCommentReplies(
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
      final dtos = await _localDataSource.getReplies(
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
      final allTrackComments = await _localDataSource.getAllCommentsForTrack(
        trackId,
      );

      final Map<int, ({String? pfp, String text})> floatingMap = {};

      for (var dto in allTrackComments) {
        final second = (dto.timestamp).floor();

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
      final newDto = CommentDto(
        id: const Uuid().v4(),
        trackId: trackId,
        userId: 'current_logged_in_user_id',
        userDisplayName: 'Current User',
        userPfp: 'https://fake-url.com/my-pfp.jpg',
        content: content,
        timestamp: trackTimestamp,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        likeCount: 0,
        isLikedByMe: false,
        replyCount: 0,
        parentCommentId: parentId,
      );

      final insertedDto = await _localDataSource.insertComment(newDto);
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
      final insertedDto = await _localDataSource.postReply(
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
      return await _localDataSource.toggleLike(commentId);
    } catch (e) {
      throw Exception('Failed to toggle like status: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _localDataSource.deleteComment(commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    try {
      await _localDataSource.blockUser(userId);
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      await _localDataSource.unblockUser(userId);
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }
}
