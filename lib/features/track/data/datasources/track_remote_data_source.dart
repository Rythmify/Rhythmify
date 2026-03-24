import '../../../../core/network/api_client.dart';

abstract class TrackRemoteDataSource {
  Future<Map<String, dynamic>> getTrackDetails(String id);
  Future<List<dynamic>> getTracks();
  Future<Map<String, dynamic>> getWaveform(String trackId);
  Future<Map<String, dynamic>> getTags();
}

class TrackRemoteDataSourceImpl implements TrackRemoteDataSource {
  final ApiClient client;

  TrackRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> getTrackDetails(String id) async {
    final response = await client.dio.get('/tracks/$id');
    // TrackDto.fromJson already handles the 'data' wrapper if it exists
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> getTracks() async {
    final response = await client.dio.get('/tracks');
    // If using json-server, this is a List. If real API, it might be { "data": [...] }
    if (response.data is Map) {
      return response.data['data'] as List<dynamic>? ?? [];
    }
    return response.data as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getWaveform(String trackId) async {
    final response = await client.dio.get('/tracks/$trackId/waveform');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getTags() async {
    final response = await client.dio.get('/tags');
    return response.data as Map<String, dynamic>;
  }
}
