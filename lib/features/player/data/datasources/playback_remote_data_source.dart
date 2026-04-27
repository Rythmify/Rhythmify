import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/history_record_model.dart';

abstract class PlaybackRemoteDataSource {
  Future<String> initiatePlayback(String trackId);
  Future<void> recordHistory(HistoryRecordModel record);
  Future<Map<String, dynamic>> fetchQueueContext({
    required String interactionType,
    required String sourceType,
    String? sourceId,
    String? targetUserId,
  });
  Future<void> syncPlayerState({
    required String trackId,
    required List<Map<String, dynamic>> queue,
    int positionSeconds = 0,
    double volume = 0.5,
  });
}

class PlaybackRemoteDataSourceImpl implements PlaybackRemoteDataSource {
  final ApiClient _apiClient;

  PlaybackRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> initiatePlayback(String trackId) async {
    try {
      final response = await _apiClient.dio.post('/tracks/$trackId/play');

      final data = response.data['data'] as Map<String, dynamic>;
      // The API returns 'stream_url', but we'll check both for robustness
      final url = data['stream_url'] as String? ?? data['url'] as String?;

      if (url == null) {
        throw Exception('Playback URL not found in API response');
      }
      return url;
    } on DioException catch (e) {
      _handleDioError(e, 'initiatePlayback');
      rethrow;
    }
  }

  @override
  Future<void> recordHistory(HistoryRecordModel record) async {
    try {
      await _apiClient.dio.post('/me/listening-history', data: record.toJson());
    } on DioException catch (e) {
      _handleDioError(e, 'recordHistory');
      // Silently fail for background history recording
    }
  }

  @override
  Future<Map<String, dynamic>> fetchQueueContext({
    required String interactionType,
    required String sourceType,
    String? sourceId,
    String? targetUserId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/me/player/queue/context',
        data: {
          'interaction_type': interactionType,
          'source_type': sourceType,
          'source_id': sourceId,
          'target_user_id': targetUserId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e, 'fetchQueueContext');
      // Return a safe empty structure if fetch fails
      return {'data': {'queue': []}};
    }
  }

  @override
  Future<void> syncPlayerState({
    required String trackId,
    required List<Map<String, dynamic>> queue,
    int positionSeconds = 0,
    double volume = 0.5,
  }) async {
    try {
      await _apiClient.dio.post(
        '/me/player/state',
        data: {
          'track_id': trackId,
          'position_seconds': positionSeconds,
          'volume': volume,
          'queue': queue,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e, 'syncPlayerState');
      // Silently fail for background state synchronization
    }
  }

  void _handleDioError(DioException e, String methodName) {
    debugPrint('[PlaybackRemoteDataSource] Error in $methodName:');
    debugPrint('  Status: ${e.response?.statusCode}');
    debugPrint('  Data: ${e.response?.data}');
    debugPrint('  Message: ${e.message}');
  }
}
