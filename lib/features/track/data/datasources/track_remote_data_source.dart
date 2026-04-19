import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Fetches the fan leaderboard for the given [trackId] and [period].
  Future<Map<String, dynamic>> getFanLeaderboard(String trackId, String period);

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

  /// Updates the cover image for the provided track.
  Future<void> updateTrackCover(String trackId, File imageFile);

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
    debugPrint('=============================================================DEBUG TRACK JSON: ${response.data}');
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
  Future<Map<String, dynamic>> getFanLeaderboard(
    String trackId,
    String period,
  ) async {
    final response = await client.dio.get(
      '/tracks/$trackId/fan-leaderboard',
      queryParameters: {'period': period},
    );
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
    final Map<String, dynamic> metadata = Map.from(data);
    String? artworkPath;

    // Extract artwork path if present
    if (metadata.containsKey('cover_image_path')) {
      artworkPath = metadata.remove('cover_image_path') as String?;
    }

    // 1. Update artwork if a new local path is provided
    if (artworkPath != null) {
      final artworkFile = File(artworkPath);
      if (await artworkFile.exists()) {
        await updateTrackCover(trackId, artworkFile);
      }
    }

    // 2. Update other metadata if any remains
    // We filter out null values to avoid overwriting existing data with nulls
    metadata.removeWhere((key, value) => value == null);

    if (metadata.isNotEmpty) {
      await client.dio.patch('/tracks/$trackId', data: metadata);
    }
  }

  @override
  Future<void> updateTrackCover(String trackId, File imageFile) async {
    final artMime = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final formData = FormData.fromMap({
      'cover_image': await MultipartFile.fromFile(
        imageFile.path,
        contentType: DioMediaType.parse(artMime),
      ),
    });

    await client.dio.patch('/tracks/$trackId/cover', data: formData);
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await client.dio.delete('/tracks/$trackId');
  }
}
