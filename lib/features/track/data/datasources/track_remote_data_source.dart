import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
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

  /// Likes the provided track on behalf of the current user.
  Future<void> likeTrack(String trackId);

  /// Removes the current user's like from the provided track.
  Future<void> unlikeTrack(String trackId);

  /// Reposts the provided track on behalf of the current user.
  Future<void> repostTrack(String trackId);

  /// Removes the current user's repost for the provided track.
  Future<void> undoRepostTrack(String trackId);

  /// Records a play for the provided track.
  Future<void> recordPlay(String trackId);

  /// Updates the metadata for the provided track.
  Future<void> updateTrack(String trackId, Map<String, dynamic> data);

  /// Deletes the provided track.
  Future<void> deleteTrack(String trackId);
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

  @override
  Future<void> likeTrack(String trackId) async {
    await client.dio.post('/tracks/$trackId/like');
  }

  @override
  Future<void> unlikeTrack(String trackId) async {
    await client.dio.delete('/tracks/$trackId/like');
  }

  @override
  Future<void> repostTrack(String trackId) async {
    await client.dio.post('/tracks/$trackId/repost');
  }

  @override
  Future<void> undoRepostTrack(String trackId) async {
    await client.dio.delete('/tracks/$trackId/repost');
  }

  @override
  Future<void> recordPlay(String trackId) async {
    await client.dio.post('/tracks/$trackId/play');
  }

  @override
  Future<void> updateTrack(String trackId, Map<String, dynamic> data) async {
    // If we have a local artwork path, we need to send as FormData
    if (data.containsKey('cover_image_path') && data['cover_image_path'] != null) {
      final artworkPath = data['cover_image_path'] as String;
      final artworkFile = File(artworkPath);
      
      if (await artworkFile.exists()) {
        final Map<String, dynamic> formDataMap = Map.from(data);
        formDataMap.remove('cover_image_path');
        
        final artMime = lookupMimeType(artworkPath) ?? 'image/jpeg';
        formDataMap['cover_image'] = await MultipartFile.fromFile(
          artworkPath,
          contentType: DioMediaType.parse(artMime),
        );

        final formData = FormData.fromMap(formDataMap);
        // Handle tags if present as a list
        if (data.containsKey('tags') && data['tags'] is List) {
          formData.fields.removeWhere((e) => e.key == 'tags');
          for (final tag in data['tags'] as List) {
            formData.fields.add(MapEntry('tags[]', tag));
          }
        }

        await client.dio.patch('/tracks/$trackId', data: formData);
        return;
      }
    }

    await client.dio.patch('/tracks/$trackId', data: data);
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await client.dio.delete('/tracks/$trackId');
  }
}
