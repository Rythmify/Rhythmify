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

  Future<List<PlaylistEntity>> fetchUserPlaylists({
    required String userId,
    int limit = 50,
  }) async {
    // For authenticated user's own playlists, use the /playlists endpoint with mine=true
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
    _log(
      '→ POST /playlists/$playlistId/tracks  trackId=$trackId  pos=$position',
    );
    try {
      final response = await _dio.post<dynamic>(
        '/playlists/$playlistId/tracks',
        data: body,
      );
      _log(
        '← ${response.statusCode}  ✅ Track $trackId added to playlist $playlistId',
      );
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
    _log(
      '→ PATCH /playlists/$playlistId/tracks/reorder  ${items.length} tracks',
    );
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
      _log('← ${response.statusCode}  keys: ${response.data?.keys}');
 
      // StationTracksResponse: { "station": {...}, "data": [...], "pagination": {...} }
      // Tracks are directly in response.data['data'] as a List — NOT nested under ['tracks']
      final rawData = response.data!['data'];
      _log('← data type: ${rawData.runtimeType}');
 
      List<dynamic> trackList;
      if (rawData is List) {
        trackList = rawData;
      } else if (rawData is Map<String, dynamic> && rawData.containsKey('tracks')) {
        // Fallback: in case server wraps them
        trackList = rawData['tracks'] as List<dynamic>? ?? [];
      } else {
        _log('← Unexpected station data shape, returning empty');
        return [];
      }
 
      _log('← Got ${trackList.length} station tracks');
      if (trackList.isNotEmpty) {
        _log('← First track keys: ${(trackList.first as Map<String, dynamic>).keys}');
      }
 
      return _mapDiscoveryTracksToPlaylistTracks(trackList);
    } on DioException catch (e) {
      _logError('fetchStationTracks($artistId) failed', e);
      return [];
    }
  }

  // ADD this method to PlaylistRemoteDatasource.
  // Place it after fetchStationTracks and before fetchRecommendedTracks.
  // ============================================================

  // ============================================================
  // ── RELATED TRACKS: for station generation
  // GET /tracks/{track_id}/related?limit=50
  //
  // Returns tracks related by same artist and same genre.
  // Used when converting a playlist to a station.
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

      // Response shape from spec:
      // { "reference_track": {...}, "data": [...DiscoveryTrack], "pagination": {...} }
      final data = response.data!['data'] as List<dynamic>;
      _log('← Got ${data.length} related tracks for $trackId');

      return _mapDiscoveryTracksToPlaylistTracks(data);
    } on DioException catch (e) {
      _logError('fetchRelatedTracks($trackId) failed', e);
      return []; // Non-fatal — station still works with fewer tracks
    }
  }

  // ============================================================
  // ADD these 3 methods to PlaylistRemoteDatasource
  // Place them after fetchRelatedTracks and before fetchRecommendedTracks
  // ============================================================

  // ── MIX TRACKS: GET /home/mixes/{mixId} ──────────────────────────────────
  // Used by MixDetailScreen for mixed_for_you genre mixes
  Future<List<PlaylistTrack>> fetchMixTracks(String mixId) async {
    _log('→ GET /home/mixes/$mixId');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/mixes/$mixId',
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>;
      _log('← Got ${tracks.length} tracks for mix $mixId');
      return _mapDiscoveryTracksToPlaylistTracks(tracks);
    } on DioException catch (e) {
      _logError('fetchMixTracks($mixId) failed', e);
      return [];
    }
  }

  // ── DAILY MIX TRACKS: GET /home/made-for-you/daily ───────────────────────
  // Used by MixDetailScreen for made_for_you daily mix
  Future<List<PlaylistTrack>> fetchDailyMixTracks() async {
    _log('→ GET /home/made-for-you/daily');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/made-for-you/daily',
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>;
      _log('← Got ${tracks.length} daily mix tracks');
      return _mapDiscoveryTracksToPlaylistTracks(tracks);
    } on DioException catch (e) {
      _logError('fetchDailyMixTracks() failed', e);
      return [];
    }
  }

  // ── WEEKLY MIX TRACKS: GET /home/made-for-you/weekly ─────────────────────
  // Used by MixDetailScreen for made_for_you weekly mix
  Future<List<PlaylistTrack>> fetchWeeklyMixTracks() async {
    _log('→ GET /home/made-for-you/weekly');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/made-for-you/weekly',
      );
      _log('← ${response.statusCode}');
      final data = response.data!['data'] as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>;
      _log('← Got ${tracks.length} weekly mix tracks');
      return _mapDiscoveryTracksToPlaylistTracks(tracks);
    } on DioException catch (e) {
      _logError('fetchWeeklyMixTracks() failed', e);
      return [];
    }
  }

  // ============================================================
  // ── RECOMMENDATIONS: Real tracks for suggestions
  //
  // Strategy:
  //   Step 1 → GET /home to extract real genre_id values
  //   Step 2 → GET /genres/{genre_id}/tracks for real UUIDs
  //
  // Why not /home tracks directly?
  //   The discover_with_stations and trending tracks in /home use
  //   seed IDs (c0000...) that don't exist in the DB → 400 on add.
  //   /genres/{id}/tracks returns tracks uploaded by real users.
  //
  // Why not hardcoded artist IDs?
  //   Those were seed users. The 39 real uploaded tracks belong to
  //   real user accounts whose IDs we discover dynamically via genres.
  // ============================================================
  Future<List<PlaylistTrack>> fetchRecommendedTracks({int limit = 5}) async {
    _log('→ fetchRecommendedTracks: two-step fetch via genres');

    try {
      // ── Step 1: Get genre IDs from /home ──────────────────────────────
      final genreIds = await _fetchGenreIdsFromHome();

      if (genreIds.isEmpty) {
        _log('← No genre IDs found, returning empty suggestions');
        return [];
      }

      _log('← Got ${genreIds.length} genre IDs: $genreIds');

      // ── Step 2: Fetch tracks from all genres in parallel ──────────────
      // We fetch from all genres so we get a wide pool of the 39 real tracks
      final responses = await Future.wait(
        genreIds.map(
          (genreId) => _dio
              .get<Map<String, dynamic>>(
                '/genres/$genreId/tracks',
                queryParameters: {'limit': 20, 'offset': 0, 'sort': 'popular'},
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

      // ── Collect and deduplicate all tracks ────────────────────────────
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
            // Skip seed/fake UUIDs — these fail when added to a playlist
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

      // Shuffle so refresh shows different tracks
      allTracks.shuffle();

      return _mapDiscoveryTracksToPlaylistTracks(
        allTracks.take(limit).toList(),
      );
    } on DioException catch (e) {
      _logError('fetchRecommendedTracks() failed', e);
      return [];
    } catch (e) {
      _log('fetchRecommendedTracks() unexpected error: $e');
      return [];
    }
  }

  /// Same as [fetchRecommendedTracks] but excludes tracks already in the playlist.
  /// Called after adding a suggestion and on refresh button tap.
  Future<List<PlaylistTrack>> fetchRecommendedTracksExcluding({
    required List<String> excludeIds,
    int limit = 5,
  }) async {
    // Fetch a larger pool, then filter
    final all = await fetchRecommendedTracks(limit: 20);
    final filtered = all.where((t) => !excludeIds.contains(t.id)).toList();
    filtered.shuffle();
    return filtered.take(limit).toList();
  }

  // ============================================================
  // ── INTERNAL: Get genre IDs from /home response
  // ============================================================
  Future<List<String>> _fetchGenreIdsFromHome() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/home');
      final data = response.data!['data'] as Map<String, dynamic>;
      final trendingByGenre = data['trending_by_genre'] as Map<String, dynamic>;
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
  // ── INTERNAL HELPER: Map DiscoveryTrack JSON → PlaylistTrack
  //
  // DiscoveryTrack shape (from /genres/{id}/tracks and /home stations):
  // {
  //   "id": "real-uuid",        ← NOT "track_id"
  //   "title": "string",
  //   "artist_name": "string",  ← flat, NOT nested
  //   "cover_image": "url",     ← nullable
  //   "duration": 213,          ← seconds as int
  //   "play_count": 4200,
  //   "stream_url": "url"       ← nullable
  // }
  // ============================================================
  List<PlaylistTrack> _mapDiscoveryTracksToPlaylistTracks(
    List<dynamic> rawList, {
    int startPosition = 1,
  }) {
    final result = <PlaylistTrack>[];
    for (int i = 0; i < rawList.length; i++) {
      try {
        final json = rawList[i] as Map<String, dynamic>;
        final id = json['id'] as String?;
        if (id == null || id.isEmpty || id.startsWith('c0000')) continue;

        result.add(
          PlaylistTrack(
            id: id,
            title: json['title'] as String? ?? 'Unknown Title',
            artistName: json['artist_name'] as String? ?? 'Unknown Artist',
            duration: Duration(
              seconds: (json['duration'] as num?)?.toInt() ?? 0,
            ),
            playCount: (json['play_count'] as num?)?.toInt() ?? 0,
            position: startPosition + i,
            coverUrl: json['cover_image'] as String?,
            isLiked: false,
            isUnavailable: false,
          ),
        );
      } catch (e) {
        _log('Error mapping track at index $i: $e');
      }
    }
    return result;
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
