import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/comment_dto.dart';

/// Abstract contract for the local data source.
abstract class CommentLocalDataSource {
  Future<List<CommentDto>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required String sortValue,
  });

  Future<List<CommentDto>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required String sortValue,
  });

  Future<List<CommentDto>> getAllCommentsForTrack(String trackId);

  Future<CommentDto> insertComment(CommentDto comment);

  Future<bool> toggleLike(String commentId);

  Future<void> deleteComment(String commentId);
}

/// Mock implementation utilizing a JSON file to simulate an API response.
/// 
/// This reads from `assets/mock_comments.json` on the first call, stores the 
/// objects in memory, and performs standard database operations (filtering, 
/// sorting, paginating) on that in-memory list.
class MockCommentLocalDataSourceImpl implements CommentLocalDataSource {
  // In-memory "database" table
  List<CommentDto> _db = [];
  bool _isInitialized = false;
  
  // Simulate network/database latency
  final Duration _delay = const Duration(milliseconds: 500);

  /// Initializes the mock database by reading the JSON file.
  /// This is called internally before any read/write operation.
  Future<void> _initDatabase() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/mock_comments.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      _db = jsonData.map((json) => CommentDto.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load mock comments JSON: $e');
    }
  }

  @override
  Future<List<CommentDto>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required String sortValue,
  }) async {
    await _initDatabase();
    await Future.delayed(_delay);

    // Filter: Match track ID AND ensure it's a root comment (no parent)
    var results = _db.where((c) => c.trackId == trackId && c.parentCommentId == null).toList();

    // Sort: Mimic SQL ORDER BY
    _sortComments(results, sortValue);

    // Paginate: Mimic SQL LIMIT & OFFSET
    final startIndex = (page - 1) * limit;
    if (startIndex >= results.length) return [];
    
    return results.skip(startIndex).take(limit).toList();
  }

  @override
  Future<List<CommentDto>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required String sortValue,
  }) async {
    await _initDatabase();
    await Future.delayed(_delay);

    // Filter by the specific parent comment ID
    var results = _db.where((c) => c.parentCommentId == commentId).toList();
    _sortComments(results, sortValue);

    final startIndex = (page - 1) * limit;
    if (startIndex >= results.length) return [];
    
    return results.skip(startIndex).take(limit).toList();
  }

  @override
  Future<List<CommentDto>> getAllCommentsForTrack(String trackId) async {
    await _initDatabase();
    await Future.delayed(_delay);
    // Used for building the floating widget map on the audio waveform
    return _db.where((c) => c.trackId == trackId).toList();
  }

  @override
  Future<CommentDto> insertComment(CommentDto comment) async {
    await _initDatabase();
    await Future.delayed(_delay);
    
    _db.add(comment);
    
    // If it's a reply, increment the replyCount of the parent comment
    if (comment.parentCommentId != null) {
      final parentIndex = _db.indexWhere((c) => c.id == comment.parentCommentId);
      if (parentIndex != -1) {
        final parent = _db[parentIndex];
       
        _db[parentIndex] = CommentDto(
          id: parent.id,
          trackId: parent.trackId,
          userId: parent.userId,
          userDisplayName: parent.userDisplayName,
          userPfp: parent.userPfp,
          content: parent.content,
          timestamp: parent.timestamp,
          createdAt: parent.createdAt,
          likeCount: parent.likeCount,
          isLikedByMe: parent.isLikedByMe,
          replyCount: parent.replyCount + 1,
          parentCommentId: parent.parentCommentId,
        );
      }
    }
    return comment;
  }

  @override
  Future<bool> toggleLike(String commentId) async {
    await _initDatabase();
    await Future.delayed(_delay);
    
    final index = _db.indexWhere((c) => c.id == commentId);
    if (index == -1) throw Exception('Comment not found in mock JSON');

    final comment = _db[index];
    final isNowLiked = !comment.isLikedByMe;
    final newLikeCount = isNowLiked ? comment.likeCount + 1 : comment.likeCount - 1;

    // Update row
    _db[index] = CommentDto(
      id: comment.id,
      trackId: comment.trackId,
      userId: comment.userId,
      userDisplayName: comment.userDisplayName,
      userPfp: comment.userPfp,
      content: comment.content,
      timestamp: comment.timestamp,
      createdAt: comment.createdAt,
      likeCount: newLikeCount,
      isLikedByMe: isNowLiked,
      replyCount: comment.replyCount,
      parentCommentId: comment.parentCommentId,
    );

    return isNowLiked;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _initDatabase();
    await Future.delayed(_delay);
    _db.removeWhere((c) => c.id == commentId);
  }

  /// Internal helper to sort comments by the requested strategy.
  void _sortComments(List<CommentDto> comments, String sortValue) {
    if (sortValue == 'newest') {
      comments.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
    } else if (sortValue == 'oldest') {
      comments.sort((a, b) => DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
    } else if (sortValue == 'top') {
      comments.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
  }
}