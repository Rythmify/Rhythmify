import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/library_models.dart';
import 'library_remote_datasource.dart';

/// Real HTTP implementation of [LibraryRemoteDatasource].
///
/// All endpoints match the Rythmify OpenAPI spec v1.0.
/// Auth token is injected automatically by [ApiClient]'s interceptor.
class LibraryRemoteDatasourceImpl implements LibraryRemoteDatasource {
  final ApiClient client;

  LibraryRemoteDatasourceImpl({required this.client});

  // ── Following ──────────────────────────────────────────────────────────────

  @override
  Future<List<FollowedUserModel>> getFollowing({
    required int page,
    required int limit,
  }) async {
    try {
      // GET /users/me -> get own ID first, then GET /users/{id}/following
      final meRes = await client.dio.get('/users/me');
      final myId = meRes.data['data']['id'] as String;

      final res = await client.dio.get(
        '/users/$myId/following',
        queryParameters: {'limit': limit, 'offset': (page - 1) * limit},
      );
      final List data = res.data['data']['items'] as List? ?? [];
      return data
          .map((e) => FollowedUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> unfollowUser({required String userId}) async {
    try {
      await client.dio.delete('/users/$userId/follow');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  @override
  Future<List<LibraryPlaylistModel>> getMyPlaylists() async {
    try {
      final res = await client.dio.get(
        '/playlists',
        queryParameters: {'mine': true, 'limit': 50},
      );
      final List items = res.data['data']['items'] as List? ?? [];
      return items
          .map(
            (e) => LibraryPlaylistModel.fromJson(
              e as Map<String, dynamic>,
              isOwned: true,
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<LibraryPlaylistModel> createPlaylist({
    required String name,
    String? description,
    required bool isPublic,
  }) async {
    try {
      final res = await client.dio.post(
        '/playlists',
        data: {
          'name': name,
          'description': ?description,
          'is_public': isPublic,
        },
      );
      return LibraryPlaylistModel.fromJson(
        res.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> deletePlaylist({required String playlistId}) async {
    try {
      await client.dio.delete('/playlists/$playlistId');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── Uploads ────────────────────────────────────────────────────────────────

  @override
  Future<List<UploadedTrackModel>> getMyUploads({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.dio.get(
        '/tracks/me',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List data = res.data['data'] as List? ?? [];
      return data
          .map((e) => UploadedTrackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> toggleTrackVisibility({
    required String trackId,
    required bool isPublic,
  }) async {
    try {
      await client.dio.patch(
        '/tracks/$trackId/visibility',
        data: {'is_public': isPublic},
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTrack({required String trackId}) async {
    try {
      await client.dio.delete('/tracks/$trackId');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── Insights ───────────────────────────────────────────────────────────────

  @override
  Future<List<TrackInsightModel>> getMyInsights() async {
    try {
      final res = await client.dio.get(
        '/tracks/me',
        queryParameters: {'limit': 50},
      );
      final List data = res.data['data'] as List? ?? [];
      return data
          .map((e) => TrackInsightModel.fromTrack(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── History ────────────────────────────────────────────────────────────────

  @override
  Future<List<RecentlyPlayedEntryModel>> getRecentlyPlayed() async {
    try {
      final res = await client.dio.get('/me/history');
      final List data = res.data['data'] as List? ?? [];
      return data
          .map(
            (e) => RecentlyPlayedEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<List<RecentlyPlayedEntryModel>> getListeningHistory({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.dio.get(
        '/me/listening-history',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List data = res.data['data'] as List? ?? [];
      return data
          .map(
            (e) => RecentlyPlayedEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> clearListeningHistory() async {
    try {
      await client.dio.delete('/me/history');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── Stations ───────────────────────────────────────────────────────────────

  @override
  Future<List<LibraryStationModel>> getStations() async {
    try {
      final res = await client.dio.get(
        '/home/stations',
        queryParameters: {'limit': 20},
      );
      final List data = res.data['data'] as List? ?? [];
      return data
          .map((e) => LibraryStationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ── Liked tracks ───────────────────────────────────────────────────────────

  @override
  Future<List<LikedTrackModel>> getLikedTracks({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.dio.get(
        '/me/liked-tracks',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List data = _extractListPayload(res.data);
      return data
          .map((e) => LikedTrackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  List<dynamic> _extractListPayload(dynamic rawResponse) {
    if (rawResponse is! Map<String, dynamic>) return [];
    final data = rawResponse['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data['items'] as List? ?? data['tracks'] as List? ?? [];
    }
    return [];
  }

  // ── Error handler ──────────────────────────────────────────────────────────

  void _handleError(DioException e) {
    final code = e.response?.data?['error']?['code'] as String?;
    final message = e.response?.data?['error']?['message'] as String?;
    switch (code) {
      case 'RESOURCE_NOT_FOUND':
        throw Exception('RESOURCE_NOT_FOUND');
      case 'PERMISSION_DENIED':
        throw Exception('PERMISSION_DENIED');
      case 'RATE_LIMIT_EXCEEDED':
        throw Exception('RATE_LIMIT_EXCEEDED');
      default:
        throw Exception(message ?? 'Unknown error occurred');
    }
  }
}
