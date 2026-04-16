import '../../data/models/comment_dto.dart';
import '../../../../core/network/api_client.dart';

/// Abstract contract for the remote API data source.
///
/// Handles network communication to fetch and mutate comments data.
abstract class CommentRemoteDataSource {
  /// Fetches paginated root comments from the API.
  Future<List<CommentDto>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required String sortValue,
  });

  /// Fetches paginated replies from the API.
  Future<List<CommentDto>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required String sortValue,
  });

  /// Returns paginated replies to the specified top-level comment.
  Future<List<CommentDto>> getReplies({
    required String commentId,
    required int limit,
    required int offset,
  });

  /// Fetches a large batch of all comments for building floating interactions.
  Future<List<CommentDto>> getAllCommentsForTrack(String trackId);

  /// Posts a new comment or reply to the API.
  Future<CommentDto> postComment({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  });

  /// Posts a reply to the specified top-level comment.
  Future<CommentDto> postReply({
    required String commentId,
    required String content,
  });

  /// Posts a like to the API.
  Future<void> likeComment(String commentId);

  /// Deletes a like from the API.
  Future<void> unlikeComment(String commentId);

  /// Deletes a comment via the API.
  Future<void> deleteComment(String commentId);

  /// Blocks a user via the API.
  Future<void> blockUser(String userId);

  /// Unblocks a user via the API.
  Future<void> unblockUser(String userId);
}

/// Concrete implementation of [CommentRemoteDataSource] using [ApiClient].
///
/// It executes actual HTTP requests to the backend server.
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates a [CommentRemoteDataSourceImpl] injected with an [_apiClient].
  CommentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CommentDto>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required String sortValue,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _apiClient.dio.get(
      '/tracks/$trackId/comments',
      queryParameters: {'limit': limit, 'offset': offset, 'sort': sortValue},
    );

    final items = response.data['data']['items'] as List;
    return items.map((json) => CommentDto.fromJson(json)).toList();
  }

  @override
  Future<List<CommentDto>> getCommentReplies({
    required String commentId,
    required int page,
    required int limit,
    required String sortValue,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _apiClient.dio.get(
      '/comments/$commentId/replies',
      queryParameters: {'limit': limit, 'offset': offset, 'sort': sortValue},
    );

    final data = response.data['data'];
    final List items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = data['items'] as List;
    } else {
      items = [];
    }

    return items.map((json) => CommentDto.fromJson(json)).toList();
  }

  @override
  Future<List<CommentDto>> getReplies({
    required String commentId,
    required int limit,
    required int offset,
  }) async {
    final response = await _apiClient.dio.get(
      '/comments/$commentId/replies',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    final data = response.data['data'];
    final List items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = data['items'] as List;
    } else {
      items = [];
    }

    return items.map((json) => CommentDto.fromJson(json)).toList();
  }

  @override
  Future<List<CommentDto>> getAllCommentsForTrack(String trackId) async {
    final response = await _apiClient.dio.get(
      '/tracks/$trackId/comments',
      queryParameters: {'limit': 20, 'offset': 0},
    );

    final items = response.data['data']['items'] as List;
    return items.map((json) => CommentDto.fromJson(json)).toList();
  }

  @override
  Future<CommentDto> postComment({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  }) async {
    final response = await _apiClient.dio.post(
      '/tracks/$trackId/comments',
      data: {
        'content': content,
        'track_timestamp': trackTimestamp,
        'parent_comment_id': parentId,
      },
    );

    return CommentDto.fromJson(response.data['data']);
  }

  @override
  Future<CommentDto> postReply({
    required String commentId,
    required String content,
  }) async {
    final response = await _apiClient.dio.post(
      '/comments/$commentId/replies',
      data: {'content': content},
    );

    return CommentDto.fromJson(response.data['data']);
  }

  @override
  Future<void> likeComment(String commentId) async {
    await _apiClient.dio.post('/comments/$commentId/like');
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    await _apiClient.dio.delete('/comments/$commentId/like');
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _apiClient.dio.delete('/comments/$commentId');
  }

  @override
  Future<void> blockUser(String userId) async {
    await _apiClient.dio.post('/users/$userId/block');
  }

  @override
  Future<void> unblockUser(String userId) async {
    await _apiClient.dio.delete('/users/$userId/block');
  }
}
