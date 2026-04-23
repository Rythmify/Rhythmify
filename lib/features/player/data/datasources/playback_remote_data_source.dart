import '../../../../core/network/api_client.dart';
import '../models/history_record_model.dart';

abstract class PlaybackRemoteDataSource {
  Future<String> initiatePlayback(String trackId);
  Future<void> recordHistory(HistoryRecordModel record);
}

class PlaybackRemoteDataSourceImpl implements PlaybackRemoteDataSource {
  final ApiClient _apiClient;

  PlaybackRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> initiatePlayback(String trackId) async {
    final response = await _apiClient.dio.post('/tracks/$trackId/play');

    final data = response.data['data'] as Map<String, dynamic>;
    // The API returns 'stream_url', but we'll check both for robustness
    final url = data['stream_url'] as String? ?? data['url'] as String?;

    if (url == null) {
      throw Exception('Playback URL not found in API response');
    }
    return url;
  }

  @override
  Future<void> recordHistory(HistoryRecordModel record) async {
    await _apiClient.dio.post('/me/listening-history', data: record.toJson());
  }
}
