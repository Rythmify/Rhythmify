import 'package:uuid/uuid.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_local_datasource.dart';
import '../../data/models/comment_dto.dart';

/// Concrete implementation of the [CommentRepository].
///
/// This implementation relies on the [CommentLocalDataSource] to simulate
/// network requests. It handles the mapping from Data layer DTOs to Domain layer Entities.
class MockCommentRepositoryImpl implements CommentRepository {
  final CommentLocalDataSource _localDataSource;

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

      // Map DTOs to Entities
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
  Future<Map<int, String>> getFloatingComments(String trackId) async {
    try {
      // Fetch all comments for the track to simulate building the waveform map
      final allTrackComments = await _localDataSource.getAllCommentsForTrack(
        trackId,
      );

      final Map<int, String> floatingMap = {};

      for (var dto in allTrackComments) {
        if (dto.userPfp == null) continue;

        final second = (dto.timestamp / 1000).floor();
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
      final newDto = CommentDto(
        id: const Uuid().v4(), // Generate a fake UUID
        trackId: trackId,
        userId: 'current_logged_in_user_id', // Mocked user session
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
  Future<bool> toggleCommentLike(
    String commentId, {
    required bool isCurrentlyLiked,
  }) async {
    try {
      // The local mock data source already handles finding the comment
      // and flipping its state internally, so we just pass the ID as before.
      return await _localDataSource.toggleLike(commentId);
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
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
}
