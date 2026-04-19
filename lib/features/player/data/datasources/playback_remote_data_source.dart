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

    // According to API spec: { "data": { "url": "..." } }
    final data = response.data['data'] as Map<String, dynamic>;
    return data['url'] as String;
  }

  @override
  Future<void> recordHistory(HistoryRecordModel record) async {
    await _apiClient.dio.post('/me/listening-history', data: record.toJson());
  }
}
