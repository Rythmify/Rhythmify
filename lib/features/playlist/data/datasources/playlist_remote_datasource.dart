// lib/features/playlist/data/datasources/playlist_remote_datasource.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import '../models/playlist_model.dart';
import '../models/playlist_track_model.dart';
import '../models/station_model.dart';

class PlaylistRemoteDatasource {
  const PlaylistRemoteDatasource(this._dio);
  final Dio _dio;

  // ============================================================
  // ── FETCH: My Playlists
  // ============================================================
  Future<List<PlaylistEntity>> fetchMyPlaylists({
    String filter = 'created',
    String? subtype,
  }) async {
    _log('→ GET /playlists  filter=$filter  subtype=${subtype ?? "any"}');
    final queryParams = <String, dynamic>{
      'mine': true,
      'filter': filter,
      'limit': 50,
    };
    if (subtype != null) queryParams['subtype'] = subtype;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/playlists',
        queryParameters: queryParams,
      );
      _log('← ${response.statusCode}  raw keys: ${response.data?.keys}');
      final outerData = response.data!['data'] as Map<String, dynamic>;
      final items = outerData['items'] as List<dynamic>;
      _log('← Got ${items.length} playlists from server');
      return PlaylistModel.fromJsonList(items);
    } on DioException catch (e) {
      _logError('fetchMyPlaylists failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── FETCH: Single Playlist Detail
  // ============================================================
  Future<PlaylistEntity> fetchPlaylistDetail(String playlistId) async {
    _log('→ GET /playlists/$playlistId');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/playlists/$playlistId',
        queryParameters: {'include_tracks': false},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      return PlaylistModel.fromJson(data);
    } on DioException catch (e) {
      _logError('fetchPlaylistDetail($playlistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── FETCH: Tracks Inside a Playlist
  // ============================================================
  Future<List<PlaylistTrack>> fetchPlaylistTracks(
    String playlistId, {
    int page = 1,
    int limit = 20,
  }) async {
    _log('→ GET /playlists/$playlistId/tracks  page=$page limit=$limit');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/playlists/$playlistId/tracks',
        queryParameters: {'page': page, 'limit': limit},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final trackList = data['tracks'] as List<dynamic>;
      _log('← Got ${trackList.length} tracks for playlist $playlistId');
      return PlaylistTrackModel.fromJsonList(trackList);
    } on DioException catch (e) {
      _logError('fetchPlaylistTracks($playlistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── FETCH: Full Track by ID (for player)
  // Endpoint: GET /tracks/{id}
  // Used by playlist_detail_screen to get the real stream_url
  // before passing to the player.
  // ============================================================
  Future<Map<String, dynamic>> fetchTrackById(String trackId) async {
    _log('→ GET /tracks/$trackId (fetching full track for player)');
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tracks/$trackId');
      _log('← ${response.statusCode}  track ready for player');
      return response.data!['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      _logError('fetchTrackById($trackId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── CREATE: New Playlist
  // ============================================================
  Future<PlaylistEntity> createPlaylist({
    required String name,
    required bool isPublic,
    String subtype = 'playlist',
  }) async {
    final body = PlaylistModel.toCreateJson(
      name: name,
      isPublic: isPublic,
      subtype: subtype,
    );
    _log('→ POST /playlists  body: $body');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/playlists',
        data: body,
      );
      _log('← ${response.statusCode} Created');
      final data = response.data!['data'] as Map<String, dynamic>;
      final created = PlaylistModel.fromJson(data);
      _log('← New playlist ID: ${created.id}  name: "${created.name}"');
      _log('✅ Playlist created successfully');
      return created;
    } on DioException catch (e) {
      _logError('createPlaylist("$name") failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── UPDATE: Playlist Metadata + Optional Cover Image
  // ============================================================
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    String? name,
    bool? isPublic,
    String? description,
    File? coverImage,
    bool removeCover = false,
    String? subtype,
    String? releaseDate,
    String? genreId,
  }) async {
    final fields = <String, dynamic>{};
    if (name != null) fields['name'] = name;
    if (isPublic != null) fields['is_public'] = isPublic;
    if (description != null) fields['description'] = description;
    if (subtype != null) fields['subtype'] = subtype;
    if (releaseDate != null) fields['release_date'] = releaseDate;
    if (genreId != null) fields['genre_id'] = genreId;
    if (removeCover) fields['remove_cover_image'] = true;
    if (coverImage != null) {
      _log('Attaching cover image: ${coverImage.path}');
      fields['cover_image'] = await MultipartFile.fromFile(
        coverImage.path,
        filename: 'cover.jpg',
      );
    }
    _log('→ PATCH /playlists/$playlistId  fields: ${fields.keys.toList()}');
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/playlists/$playlistId',
        data: FormData.fromMap(fields),
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final updated = PlaylistModel.fromJson(data);
      _log('✅ Playlist updated. Cover URL: ${updated.coverUrl ?? "none"}');
      return updated;
    } on DioException catch (e) {
      _logError('updatePlaylist($playlistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── DELETE: Playlist
  // ============================================================
  Future<void> deletePlaylist(String playlistId) async {
    _log('→ DELETE /playlists/$playlistId');
    try {
      final response = await _dio.delete<void>('/playlists/$playlistId');
      _log('← ${response.statusCode}  ✅ Playlist $playlistId deleted from DB');
    } on DioException catch (e) {
      _logError('deletePlaylist($playlistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── ADD TRACK to Playlist
  // ============================================================
  Future<void> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
    int? position,
  }) async {
    final body = <String, dynamic>{'track_id': trackId};
    if (position != null) body['position'] = position;
    _log('→ POST /playlists/$playlistId/tracks  trackId=$trackId  pos=$position');
    try {
      final response = await _dio.post<dynamic>(
        '/playlists/$playlistId/tracks',
        data: body,
      );
      _log('← ${response.statusCode}  ✅ Track $trackId added to playlist $playlistId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _log('⚠️ Track $trackId already exists in playlist $playlistId (409)');
        return;
      }
      _logError('addTrackToPlaylist failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── REMOVE TRACK from Playlist
  // ============================================================
  Future<void> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    _log('→ DELETE /playlists/$playlistId/tracks/$trackId');
    try {
      final response = await _dio.delete<dynamic>(
        '/playlists/$playlistId/tracks/$trackId',
      );
      _log('← ${response.statusCode}  ✅ Track $trackId removed');
    } on DioException catch (e) {
      _logError('removeTrackFromPlaylist failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── REORDER TRACKS in Playlist
  // ============================================================
  Future<void> reorderPlaylistTracks({
    required String playlistId,
    required List<String> orderedTrackIds,
  }) async {
    final items = orderedTrackIds
        .asMap()
        .entries
        .map((entry) => {
              'track_id': entry.value,
              'position': entry.key + 1,
            })
        .toList();
    _log('→ PATCH /playlists/$playlistId/tracks/reorder  ${items.length} tracks');
    try {
      final response = await _dio.patch<dynamic>(
        '/playlists/$playlistId/tracks/reorder',
        data: {'items': items},
      );
      _log('← ${response.statusCode}  ✅ Tracks reordered');
    } on DioException catch (e) {
      _logError('reorderPlaylistTracks failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── ENGAGEMENT: Like / Unlike
  // ============================================================
  Future<void> likePlaylist(String id) async {
    _log('→ POST /playlists/$id/like');
    try {
      await _dio.post<dynamic>('/playlists/$id/like');
      _log('← ✅ Liked playlist $id');
    } on DioException catch (e) {
      _logError('likePlaylist($id) failed', e);
      rethrow;
    }
  }

  Future<void> unlikePlaylist(String id) async {
    _log('→ DELETE /playlists/$id/like');
    try {
      await _dio.delete<dynamic>('/playlists/$id/like');
      _log('← ✅ Unliked playlist $id');
    } on DioException catch (e) {
      _logError('unlikePlaylist($id) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── ENGAGEMENT: Repost / Remove Repost
  // ============================================================
  Future<void> repostPlaylist(String id) async {
    _log('→ POST /playlists/$id/repost');
    try {
      await _dio.post<dynamic>('/playlists/$id/repost');
      _log('← ✅ Reposted playlist $id');
    } on DioException catch (e) {
      _logError('repostPlaylist($id) failed', e);
      rethrow;
    }
  }

  Future<void> removeRepost(String id) async {
    _log('→ DELETE /playlists/$id/repost');
    try {
      await _dio.delete<dynamic>('/playlists/$id/repost');
      _log('← ✅ Removed repost for playlist $id');
    } on DioException catch (e) {
      _logError('removeRepost($id) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── STATIONS: Fetch List
  // ============================================================
  Future<List<PlaylistEntity>> fetchStations({int limit = 10}) async {
    _log('→ GET /home (reading discover_with_stations)  limit=$limit');
    try {
      final response = await _dio.get<Map<String, dynamic>>('/home');
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final stations = data['discover_with_stations'] as List<dynamic>;
      _log('← Got ${stations.length} stations');
      return StationModel.fromJsonList(stations.take(limit).toList());
    } on DioException catch (e) {
      _logError('fetchStations() failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── STATIONS: Fetch Tracks
  // ============================================================
  Future<List<PlaylistTrack>> fetchStationTracks(
    String artistId, {
    int limit = 50,
  }) async {
    _log('→ GET /home/stations/$artistId/tracks  limit=$limit');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/stations/$artistId/tracks',
        queryParameters: {'limit': limit},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final trackList = data['tracks'] as List<dynamic>;
      _log('← Got ${trackList.length} station tracks');
      return _mapUserTracksToPlaylistTracks(trackList);
    } on DioException catch (e) {
      _logError('fetchStationTracks($artistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── RECOMMENDATIONS: Real tracks for suggestions
  //
  // Fetches from GET /users/{artistId}/tracks — confirmed real tracks.
  //
  // SEED ID FILTER:
  //   Some of DJ Karim's tracks have seed IDs like "c0000018-..."
  //   that fail POST /playlists/{id}/tracks with 400 even though they
  //   appear in the tracks listing. We filter these out so only
  //   tracks with standard UUIDs are shown as suggestions.
  //   Standard UUIDs follow xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  //   where the first segment is 8 hex chars (not "c0000xxx").
  // ============================================================
Future<List<PlaylistTrack>> fetchRecommendedTracks({int limit = 5}) async {
  // GET /tracks returns 404 — not deployed on the server yet.
  // Fetching from known artists in parallel as a working fallback.
  // Replace with GET /tracks once backend deploys it.
  const artistIds = [
    '00000002-0000-0000-0000-000000000000', // DJ Karim
    '00000004-0000-0000-0000-000000000000', // Omar Farouk
    '00000003-0000-0000-0000-000000000000', // Nour El Sound
    '00000005-0000-0000-0000-000000000000', // Layla Jazz
    '00000006-0000-0000-0000-000000000000', // SynthLord
    '00000007-0000-0000-0000-000000000000', // Rana Beats
  ];

  _log('→ Fetching tracks from ${artistIds.length} artists in parallel');

  try {
    final responses = await Future.wait(
      artistIds.map((id) => _dio.get<Map<String, dynamic>>(
        '/users/$id/tracks',
        queryParameters: {'limit': 10},
      )),
    );

    final allTracks = <dynamic>[];
    for (final response in responses) {
      final data = response.data!['data'] as List<dynamic>? ?? [];
      allTracks.addAll(data);
    }

    _log('← Got ${allTracks.length} total tracks from all artists');

    final realTracks = allTracks.where((t) {
      final id = (t as Map<String, dynamic>)['id'] as String? ?? '';
      return !id.startsWith('c0000');
    }).toList();

    _log('← ${realTracks.length} real tracks after filtering seed IDs');

    if (realTracks.isEmpty) return [];

    realTracks.shuffle();
    return _mapUserTracksToPlaylistTracks(realTracks.take(limit).toList());
  } on DioException catch (e) {
    _logError('fetchRecommendedTracks() failed', e);
    return [];
  }
}

  // ============================================================
  // ── INTERNAL HELPER: Map user track JSON → PlaylistTrack
  // ============================================================
  List<PlaylistTrack> _mapUserTracksToPlaylistTracks(
    List<dynamic> rawList, {
    int startPosition = 1,
  }) {
    return rawList.asMap().entries.map((entry) {
      final index = entry.key;
      final json = entry.value as Map<String, dynamic>;
      return PlaylistTrack(
        id: json['id'] as String,
        title: json['title'] as String,
        artistName: json['artist_name'] as String? ?? 'Unknown Artist',
        duration: Duration(seconds: json['duration'] as int? ?? 0),
        playCount: json['play_count'] as int? ?? 0,
        position: startPosition + index,
        coverUrl: json['cover_image'] as String?,
        isUnavailable: false,
      );
    }).toList();
  }

  // ============================================================
  // ── LOGGING HELPERS
  // ============================================================
  void _log(String message) {
    // ignore: avoid_print
    print('[DATASOURCE] $message');
  }

  void _logError(String context, DioException e) {
    // ignore: avoid_print
    print('[DATASOURCE] ❌ ERROR in $context');
    // ignore: avoid_print
    print('[DATASOURCE]    Status: ${e.response?.statusCode}');
    // ignore: avoid_print
    print('[DATASOURCE]    Message: ${e.message}');
    // ignore: avoid_print
    print('[DATASOURCE]    Response body: ${e.response?.data}');
  }
}