import '../../data/models/comment_dto.dart';
import '../../../../core/network/api_client.dart';

abstract class CommentRemoteDataSource {
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

  Future<CommentDto> postComment({
    required String trackId,
    required String content,
    required int trackTimestamp,
    String? parentId,
  });

  Future<void> likeComment(String commentId);

  Future<void> unlikeComment(String commentId);

  Future<void> deleteComment(String commentId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final ApiClient _apiClient;

  CommentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CommentDto>> getTrackComments({
    required String trackId,
    required int page,
    required int limit,
    required String sortValue,
  }) async {
    // Convert page/limit to offset for the API
    final offset = (page - 1) * limit;

    final response = await _apiClient.dio.get(
      '/tracks/$trackId/comments',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        // The API defaults to sort, passing it down from the repository
        'sort': sortValue,
      },
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

    final items = response.data['data']['items'] as List;
    return items.map((json) => CommentDto.fromJson(json)).toList();
  }

  @override
  Future<List<CommentDto>> getAllCommentsForTrack(String trackId) async {
    // Fetches a large batch for the audio waveform floating comments
    final response = await _apiClient.dio.get(
      '/tracks/$trackId/comments',
      queryParameters: {'limit': 1000, 'offset': 0},
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
        'parent_comment_id': ?parentId,
      },
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
}
