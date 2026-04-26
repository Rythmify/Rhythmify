// lib/features/playlist/data/datasources/playlist_remote_datasource.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import '../models/playlist_model.dart';
import '../models/playlist_track_model.dart';
import '../models/station_model.dart';
import '../../data/local/local_saved_store.dart';

class PlaylistRemoteDatasource {
  const PlaylistRemoteDatasource(this._dio);
  final Dio _dio;

  // ============================================================
  // ── FETCH: My Playlists (owned — filter=created)
  // KEY FIX: uses fromJsonListOwned so every returned playlist
  // gets isOwned=true. This is the only reliable way to mark
  // ownership — comparing ownerId to currentUserId fails because
  // seed users and real users can share IDs unpredictably.
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

      // CRITICAL: use fromJsonListOwned for filter=created
      // so isOwned=true on every item, regardless of ownerId value.
      if (filter == 'created') {
        return PlaylistModel.fromJsonListOwned(items);
      }
      return PlaylistModel.fromJsonList(items);
    } on DioException catch (e) {
      _logError('fetchMyPlaylists failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── FETCH: Liked Playlists (GET /me/liked-playlists)
  // Returns mixes, generated playlists, and regular liked playlists.
  // All returned with isOwned=false.
  // Cover and trackCount enriched from LocalSavedStore for generated
  // playlists where the backend returns null/0.
  // ============================================================
  Future<List<PlaylistEntity>> fetchLikedPlaylists({
    int limit = 50,
    int offset = 0,
  }) async {
    _log('→ GET /me/liked-playlists  limit=$limit offset=$offset');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/me/liked-playlists',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      _log('← ${response.statusCode}');
      final outerData = response.data!['data'] as Map<String, dynamic>;
      final items = outerData['items'] as List<dynamic>;
      _log('← Got ${items.length} liked playlists');

      final savedMixes = await LocalSavedStore.instance.getMixes();
      final mixById = {for (final m in savedMixes) m.mixId: m};

      return items
          .cast<Map<String, dynamic>>()
          .map((json) => _likedItemFromJson(json, mixById))
          .toList();
    } on DioException catch (e) {
      _logError('fetchLikedPlaylists() failed', e);
      rethrow;
    }
  }

  PlaylistEntity _likedItemFromJson(
    Map<String, dynamic> json,
    Map<String, SavedMix> localMixes,
  ) {
    _log('[LIKED] RAW: $json');

    final id = json['id'] as String;
    final local = localMixes[id];

    final backendCover = json['cover_image'] as String?;
    final coverUrl =
        (backendCover != null && backendCover.isNotEmpty)
            ? backendCover
            : local?.coverUrl;

    final backendTrackCount = (json['track_count'] as num?)?.toInt() ?? 0;
    final trackCount =
        backendTrackCount > 0 ? backendTrackCount : (local?.trackCount ?? 0);

    return PlaylistEntity(
      id: id,
      name: json['title'] as String? ?? local?.title ?? 'Untitled',
      ownerName: json['display_name'] as String? ?? local?.ownerName ?? '',
      ownerId: json['user_id'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      type: PlaylistType.playlist,
      trackCount: trackCount,
      totalDuration: Duration.zero,
      createdAt: json['liked_at'] != null
          ? DateTime.parse(json['liked_at'] as String)
          : DateTime.now(),
      coverUrl: coverUrl,
      description: json['description'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: true,
      isOwned: false,
    );
  }

  // ============================================================
  // ── FETCH: User Playlists
  // ============================================================
  Future<List<PlaylistEntity>> fetchUserPlaylists({
    required String userId,
    int limit = 50,
  }) async {
    final isMine = userId == 'me';
    final endpoint = isMine ? '/playlists' : '/users/$userId/playlists';

    _log('→ GET $endpoint  limit=$limit ${isMine ? '(mine=true)' : ''}');
    final queryParams = <String, dynamic>{'limit': limit};
    if (isMine) {
      queryParams['mine'] = true;
      queryParams['filter'] = 'created';
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
      );
      _log('← ${response.statusCode}  raw keys: ${response.data?.keys}');
      final outerData = response.data!['data'] as Map<String, dynamic>;
      final items = outerData['items'] as List<dynamic>;
      _log('← Got ${items.length} playlists from server');
      return PlaylistModel.fromJsonList(items);
    } on DioException catch (e) {
      _logError('fetchUserPlaylists($userId) failed', e);
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
  // Used for owned playlists (regular subtype).
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
  // ── FETCH: Track Radio Tracks
  // Used for liked track radios (subtype: track_radio).
  // Endpoint: GET /playlists/:id/radio-tracks
  // Response: { data: { tracks: [...DiscoveryTrack] } }
  // ============================================================
  Future<List<PlaylistTrack>> fetchRadioTracks(
    String playlistId, {
    int limit = 20,
    int offset = 0,
  }) async {
    _log('→ GET /playlists/$playlistId/radio-tracks  limit=$limit offset=$offset');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/playlists/$playlistId/radio-tracks',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final trackList = data['tracks'] as List<dynamic>;
      _log('← Got ${trackList.length} radio tracks for $playlistId');
      return _mapDiscoveryTracksToPlaylistTracks(trackList);
    } on DioException catch (e) {
      _logError('fetchRadioTracks($playlistId) failed', e);
      return [];
    }
  }

  // ============================================================
  // ── FETCH: Full Track by ID (for player)
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
      // Newly created playlist is always owned
      final created = PlaylistModel.fromJson(data, isOwned: true);
      _log('← New playlist ID: ${created.id}  name: "${created.name}"');
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
      // Updated playlist is owned by definition
      final updated = PlaylistModel.fromJson(data, isOwned: true);
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
      _log('← ${response.statusCode}  ✅ Playlist $playlistId deleted');
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
      _log('← ${response.statusCode}  ✅ Track $trackId added');
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
        .map((entry) => {'track_id': entry.value, 'position': entry.key + 1})
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
  // ── ENGAGEMENT: Like / Unlike Playlist
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
  // ── ENGAGEMENT: Like / Unlike Mix
  // ============================================================
  Future<void> likeMix(String mixId) async {
    _log('→ POST /home/mixes/$mixId/like');
    try {
      await _dio.post<dynamic>('/home/mixes/$mixId/like');
      _log('← ✅ Liked mix $mixId');
    } on DioException catch (e) {
      _logError('likeMix($mixId) failed', e);
      rethrow;
    }
  }

  Future<void> unlikeMix(String mixId) async {
    _log('→ DELETE /home/mixes/$mixId/like');
    try {
      await _dio.delete<dynamic>('/home/mixes/$mixId/like');
      _log('← ✅ Unliked mix $mixId');
    } on DioException catch (e) {
      _logError('unlikeMix($mixId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── ENGAGEMENT: Like / Unlike Station
  // ============================================================
  Future<void> likeStation(String artistId) async {
    _log('→ POST /stations/$artistId/like');
    try {
      await _dio.post<dynamic>('/stations/$artistId/like');
      _log('← ✅ Saved station $artistId');
    } on DioException catch (e) {
      _logError('likeStation($artistId) failed', e);
      rethrow;
    }
  }

  Future<void> unlikeStation(String artistId) async {
    _log('→ DELETE /stations/$artistId/like');
    try {
      await _dio.delete<dynamic>('/stations/$artistId/like');
      _log('← ✅ Removed station $artistId');
    } on DioException catch (e) {
      _logError('unlikeStation($artistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── ENGAGEMENT: Like / Unlike Track Radio
  // POST /tracks/:track_id/like-radio → returns playlist_id
  // ============================================================
  Future<String?> likeTrackRadio(String trackId) async {
    _log('→ POST /tracks/$trackId/like-radio');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tracks/$trackId/like-radio',
      );
      _log('← ${response.statusCode}  ✅ Track radio saved for $trackId');
      final data = response.data?['data'] as Map<String, dynamic>?;
      return data?['playlist_id'] as String?;
    } on DioException catch (e) {
      _logError('likeTrackRadio($trackId) failed', e);
      rethrow;
    }
  }

  Future<void> unlikeTrackRadio(String trackId) async {
    _log('→ DELETE /tracks/$trackId/like-radio');
    try {
      await _dio.delete<dynamic>('/tracks/$trackId/like-radio');
      _log('← ✅ Track radio removed for $trackId');
    } on DioException catch (e) {
      _logError('unlikeTrackRadio($trackId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── FETCH: Saved Stations (GET /users/me/stations)
  // ============================================================
  Future<List<SavedStation>> fetchSavedStations({
    int limit = 20,
    int offset = 0,
  }) async {
    _log('→ GET /users/me/stations  limit=$limit offset=$offset');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/stations',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as List<dynamic>;
      _log('← Got ${data.length} saved stations');
      return data.map((json) {
        final j = json as Map<String, dynamic>;
        return SavedStation(
          artistId: j['artist_id'] as String,
          artistName: j['artist_name'] as String? ?? 'Unknown Artist',
          stationName: '${j['artist_name'] ?? 'Unknown'} Radio',
          coverUrl: j['profile_picture'] as String?,
          trackCount: (j['track_count'] as num?)?.toInt() ?? 0,
          savedAt: j['saved_at'] != null
              ? DateTime.parse(j['saved_at'] as String)
              : DateTime.now(),
        );
      }).toList();
    } on DioException catch (e) {
      _logError('fetchSavedStations() failed', e);
      return [];
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
  // ── STATIONS: Fetch List from home
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
      _log('← ${response.statusCode}  keys: ${response.data?.keys}');

      final rawData = response.data!['data'];
      _log('← data type: ${rawData.runtimeType}');

      List<dynamic> trackList;
      if (rawData is List) {
        trackList = rawData;
      } else if (rawData is Map<String, dynamic> &&
          rawData.containsKey('tracks')) {
        trackList = rawData['tracks'] as List<dynamic>? ?? [];
      } else {
        _log('← Unexpected station data shape, returning empty');
        return [];
      }

      _log('← Got ${trackList.length} station tracks');
      return _mapDiscoveryTracksToPlaylistTracks(trackList);
    } on DioException catch (e) {
      _logError('fetchStationTracks($artistId) failed', e);
      return [];
    }
  }

  // ============================================================
  // ── RELATED TRACKS
  // ============================================================
  Future<List<PlaylistTrack>> fetchRelatedTracks(
    String trackId, {
    int limit = 50,
  }) async {
    _log('→ GET /tracks/$trackId/related  limit=$limit');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tracks/$trackId/related',
        queryParameters: {'limit': limit, 'offset': 0},
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>;
      _log('← Got ${tracks.length} related tracks for $trackId');
      return _mapDiscoveryTracksToPlaylistTracks(tracks);
    } on DioException catch (e) {
      _logError('fetchRelatedTracks($trackId) failed', e);
      return [];
    }
  }

  // ============================================================
  // ── MIX TRACKS: GET /home/mixes/:mixId
  // Only for persisted mix UUIDs (mixed_for_you, made_for_you).
  // Does NOT work for liked playlist UUIDs — use fetchPlaylistTracks.
  // ============================================================
  Future<List<PlaylistTrack>> fetchMixTracks(String mixId) async {
    _log('→ GET /home/mixes/$mixId');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/mixes/$mixId',
      );
      _log('← ${response.statusCode}  keys: ${response.data?.keys}');

      final rawData = response.data!['data'];
      _log('← data type: ${rawData.runtimeType}');

      List<dynamic> trackList;
      if (rawData is Map<String, dynamic>) {
        trackList = rawData['tracks'] as List<dynamic>? ?? [];
      } else if (rawData is List) {
        trackList = rawData;
      } else {
        _log('← Unexpected data shape, returning empty');
        return [];
      }

      _log('← Raw track count: ${trackList.length}');
      return _mapDiscoveryTracksToPlaylistTracksNoFilter(trackList);
    } on DioException catch (e) {
      _logError('fetchMixTracks($mixId) failed', e);
      return [];
    }
  }

  Future<List<PlaylistTrack>> fetchDailyMixTracks() async {
    _log('→ GET /home/made-for-you/daily');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/made-for-you/daily',
      );
      _log('← ${response.statusCode}  keys: ${response.data?.keys}');
      final rawData = response.data!['data'];
      List<dynamic> trackList;
      if (rawData is Map<String, dynamic>) {
        trackList = rawData['tracks'] as List<dynamic>? ?? [];
      } else if (rawData is List) {
        trackList = rawData;
      } else {
        return [];
      }
      _log('← Daily mix raw track count: ${trackList.length}');
      return _mapDiscoveryTracksToPlaylistTracksNoFilter(trackList);
    } on DioException catch (e) {
      _logError('fetchDailyMixTracks() failed', e);
      return [];
    }
  }

  Future<List<PlaylistTrack>> fetchWeeklyMixTracks() async {
    _log('→ GET /home/made-for-you/weekly');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/made-for-you/weekly',
      );
      _log('← ${response.statusCode}  keys: ${response.data?.keys}');
      final rawData = response.data!['data'];
      List<dynamic> trackList;
      if (rawData is Map<String, dynamic>) {
        trackList = rawData['tracks'] as List<dynamic>? ?? [];
      } else if (rawData is List) {
        trackList = rawData;
      } else {
        return [];
      }
      _log('← Weekly mix raw track count: ${trackList.length}');
      return _mapDiscoveryTracksToPlaylistTracksNoFilter(trackList);
    } on DioException catch (e) {
      _logError('fetchWeeklyMixTracks() failed', e);
      return [];
    }
  }

  // ============================================================
  // ── RECOMMENDATIONS
  // ============================================================
  Future<List<PlaylistTrack>> fetchRecommendedTracks({int limit = 5}) async {
    _log('→ fetchRecommendedTracks: two-step fetch via genres');
    try {
      final genreIds = await _fetchGenreIdsFromHome();
      if (genreIds.isEmpty) return [];
      _log('← Got ${genreIds.length} genre IDs: $genreIds');

      final responses = await Future.wait(
        genreIds.map(
          (genreId) => _dio
              .get<Map<String, dynamic>>(
                '/genres/$genreId/tracks',
                queryParameters: {
                  'limit': 20,
                  'offset': 0,
                  'sort': 'popular',
                },
              )
              .catchError((e) {
                _log('Genre $genreId fetch failed, skipping: $e');
                return Response<Map<String, dynamic>>(
                  requestOptions: RequestOptions(path: ''),
                  data: null,
                );
              }),
        ),
      );

      final seenIds = <String>{};
      final allTracks = <dynamic>[];

      for (final response in responses) {
        if (response.data == null) continue;
        try {
          final outerData = response.data!['data'];
          List<dynamic> tracks;
          if (outerData is List) {
            tracks = outerData;
          } else if (outerData is Map && outerData.containsKey('tracks')) {
            tracks = outerData['tracks'] as List<dynamic>;
          } else {
            continue;
          }
          for (final t in tracks) {
            final id = (t as Map<String, dynamic>)['id'] as String?;
            if (id == null || id.isEmpty) continue;
            if (id.startsWith('c0000')) continue;
            if (seenIds.contains(id)) continue;
            seenIds.add(id);
            allTracks.add(t);
          }
        } catch (e) {
          _log('Error parsing genre response: $e');
        }
      }

      _log('← Got ${allTracks.length} unique real tracks across all genres');
      if (allTracks.isEmpty) return [];
      allTracks.shuffle();
      return _mapDiscoveryTracksToPlaylistTracks(
          allTracks.take(limit).toList());
    } on DioException catch (e) {
      _logError('fetchRecommendedTracks() failed', e);
      return [];
    } catch (e) {
      _log('fetchRecommendedTracks() unexpected error: $e');
      return [];
    }
  }

  Future<List<PlaylistTrack>> fetchRecommendedTracksExcluding({
    required List<String> excludeIds,
    int limit = 5,
  }) async {
    final all = await fetchRecommendedTracks(limit: 20);
    final filtered = all.where((t) => !excludeIds.contains(t.id)).toList();
    filtered.shuffle();
    return filtered.take(limit).toList();
  }

  // ============================================================
  // ── INTERNAL: Genre IDs from /home
  // ============================================================
  Future<List<String>> _fetchGenreIdsFromHome() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/home');
      final data = response.data!['data'] as Map<String, dynamic>;
      final trendingByGenre =
          data['trending_by_genre'] as Map<String, dynamic>;
      final genres = trendingByGenre['genres'] as List<dynamic>;
      return genres
          .map((g) => (g as Map<String, dynamic>)['genre_id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      _log('_fetchGenreIdsFromHome failed: $e');
      return [];
    }
  }

  // ============================================================
  // ── INTERNAL HELPERS
  // ============================================================

  // No-filter mapper — for mixes/stations/related (display-only)
  List<PlaylistTrack> _mapDiscoveryTracksToPlaylistTracksNoFilter(
    List<dynamic> rawList, {
    int startPosition = 1,
  }) {
    final result = <PlaylistTrack>[];
    for (int i = 0; i < rawList.length; i++) {
      try {
        final json = rawList[i] as Map<String, dynamic>;
        final id = (json['id'] ?? json['track_id']) as String?;
        if (id == null || id.isEmpty) {
          _log('  Skipping track at index $i — no id. Keys: ${json.keys}');
          continue;
        }
        result.add(PlaylistTrack(
          id: id,
          title: json['title'] as String? ?? 'Unknown Title',
          artistName: json['artist_name'] as String? ?? 'Unknown Artist',
          duration:
              Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0),
          playCount: (json['play_count'] as num?)?.toInt() ?? 0,
          position: startPosition + i,
          coverUrl: json['cover_image'] as String?,
          isLiked: false,
          isUnavailable: false,
        ));
      } catch (e) {
        _log('  Error mapping mix track at index $i: $e');
      }
    }
    _log('  Mapped ${result.length} mix tracks from ${rawList.length} raw');
    return result;
  }

  // Standard mapper — c0000 tracks pass through (display-only)
  List<PlaylistTrack> _mapDiscoveryTracksToPlaylistTracks(
    List<dynamic> rawList, {
    int startPosition = 1,
  }) {
    final result = <PlaylistTrack>[];
    for (int i = 0; i < rawList.length; i++) {
      try {
        final json = rawList[i] as Map<String, dynamic>;
        final id = (json['id'] ?? json['track_id']) as String?;
        if (id == null || id.isEmpty) continue;
        result.add(PlaylistTrack(
          id: id,
          title: json['title'] as String? ?? 'Unknown Title',
          artistName: json['artist_name'] as String? ?? 'Unknown Artist',
          duration:
              Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0),
          playCount: (json['play_count'] as num?)?.toInt() ?? 0,
          position: startPosition + i,
          coverUrl: json['cover_image'] as String?,
          isLiked: false,
          isUnavailable: false,
        ));
      } catch (e) {
        _log('Error mapping track at index $i: $e');
      }
    }
    return result;
  }

  // ============================================================
  // ── LOGGING
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