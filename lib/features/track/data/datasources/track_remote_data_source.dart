import '../../../../core/network/api_client.dart';

abstract class TrackRemoteDataSource {
  Future<Map<String, dynamic>> getTrackDetails(String id);
  Future<Map<String, dynamic>> getWaveform(String trackId);
  Future<Map<String, dynamic>> getTags();
}

class TrackRemoteDataSourceImpl implements TrackRemoteDataSource {
  final ApiClient client;

  TrackRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> getTrackDetails(String id) async {
    final response = await client.dio.get('/tracks/$id');
    // Extract the inner 'data' map from the standard response envelope
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getWaveform(String trackId) async {
    final response = await client.dio.get('/tracks/$trackId/waveform');
    // Extract the inner 'data' map
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getTags() async {
    final response = await client.dio.get('/tags');
    // Extract the inner 'data' map (the {uuid: name} dictionary)
    return response.data['data'] as Map<String, dynamic>;
  }
}
