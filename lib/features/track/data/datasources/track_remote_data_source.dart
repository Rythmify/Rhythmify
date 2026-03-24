import '../../../../core/network/api_client.dart';

/// [TrackRemoteDataSource] defines the interface for remote track data operations.
///
/// This data source interacts with the backend via the [ApiClient]
/// to perform CRUD operations on tracks.
abstract class TrackRemoteDataSource {
  /// Fetches track details from the backend for the given track [id].
  Future<Map<String, dynamic>> getTrackDetails(String id);

  /// Retrieves a list of all tracks from the remote server.
  Future<List<dynamic>> getTracks();

  /// Fetches the waveform data for the given [trackId] from the remote API.
  Future<Map<String, dynamic>> getWaveform(String trackId);

  /// Fetches the full list of available tags from the remote API.
  Future<Map<String, dynamic>> getTags();
}

/// [TrackRemoteDataSourceImpl] implements [TrackRemoteDataSource] using [ApiClient].
class TrackRemoteDataSourceImpl implements TrackRemoteDataSource {
  final ApiClient client;

  TrackRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> getTrackDetails(String id) async {
    final response = await client.dio.get('/tracks/$id');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> getTracks() async {
    final response = await client.dio.get('/tracks');
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
