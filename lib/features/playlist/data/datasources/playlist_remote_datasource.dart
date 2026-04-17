// ============================================================
// FILE: lib/features/playlist/data/datasources/playlist_remote_datasource.dart
//
// PURPOSE: This is the ONLY place that sends HTTP requests.
//          Every method = one API endpoint.
//          It does NOT know about Riverpod or UI — it just
//          makes requests and returns raw parsed objects.
//
// STAGE: 2 of 7 — Datasource
//
// HOW ERRORS WORK:
//   - Dio throws a DioException when the server returns 4xx or 5xx
//   - We let those bubble up to the provider (Stage 3) which
//     catches them and shows the right error message to the user
//
// HOW TO VERIFY EACH METHOD:
//   Watch the Flutter console. You'll see:
//   [DATASOURCE] → POST /playlists  body: {name: Gym Mix, ...}
//   [DATASOURCE] ← 201 Created  playlist_id: abc-123
//   Then check your backend's database — the row should be there.
// ============================================================

import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import '../models/playlist_model.dart';
import '../models/playlist_track_model.dart';
import '../models/station_model.dart';

class PlaylistRemoteDatasource {
  // The Dio instance is provided by your team leader's ApiClient.
  // It already has the base URL and JWT token interceptor attached,
  // so you never need to set headers manually here.
  const PlaylistRemoteDatasource(this._dio);
  final Dio _dio;

  // ============================================================
  // ── FETCH: My Playlists ─────────────────────────────────────
  // Endpoint: GET /playlists?mine=true&filter=created
  //
  // Called by: LibraryPlaylistsScreen on first load
  //
  // filter param:
  //   "created" → playlists I own
  //   "liked"   → playlists I liked (for liked playlists section)
  //
  // Response shape:
  // {
  //   "data": {
  //     "items": [ { playlist object }, ... ],
  //     "meta": { "total": 5, ... }
  //   }
  // }
  // ============================================================
  Future<List<PlaylistEntity>> fetchMyPlaylists({
    String filter = 'created',
    String? subtype, // pass 'album' to get only albums, etc.
  }) async {
    _log('→ GET /playlists  filter=$filter  subtype=${subtype ?? "any"}');

    final queryParams = <String, dynamic>{
      'mine': true,
      'filter': filter,
      'limit': 50, // fetch up to 50 at once; add pagination later if needed
    };

    // If the caller wants only albums/stations, add the subtype filter.
    // For stations we use a different endpoint entirely (see fetchStations).
    if (subtype != null) {
      queryParams['subtype'] = subtype;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/playlists',
        queryParameters: queryParams,
      );

      _log('← ${response.statusCode}  raw keys: ${response.data?.keys}');

      // Navigate the nested response:
      // response.data = { "data": { "items": [...] }, "message": "..." }
      final outerData = response.data!['data'] as Map<String, dynamic>;
      final items = outerData['items'] as List<dynamic>;

      _log('← Got ${items.length} playlists from server');

      return PlaylistModel.fromJsonList(items);
    } on DioException catch (e) {
      _logError('fetchMyPlaylists failed', e);
      rethrow; // Provider will catch this
    }
  }

  // ============================================================
  // ── FETCH: Single Playlist Detail ──────────────────────────
  // Endpoint: GET /playlists/{id}?include_tracks=false
  //
  // Called by: PlaylistDetailScreen header section
  //
  // We fetch tracks separately via fetchPlaylistTracks() so we
  // can paginate them independently.
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
  // ── FETCH: Tracks Inside a Playlist ─────────────────────────
  // Endpoint: GET /playlists/{id}/tracks?page=1&limit=20
  //
  // Called by: PlaylistDetailScreen track list
  //
  // Supports pagination — call with page=2, 3, etc. for more.
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

      // Response shape:
      // { "data": { "playlist_id": "...", "tracks": [...], "pagination": {...} } }
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
  // ── CREATE: New Playlist ─────────────────────────────────────
  // Endpoint: POST /playlists
  // Body: { "name": "...", "is_public": true, "subtype": "playlist" }
  //
  // Called by: CreatePlaylistSheet._onSave()
  //
  // Returns: the newly created PlaylistEntity (with its new ID
  //          assigned by the database)
  //
  // subtype options:
  //   "playlist"    → regular playlist (LibraryPlaylistsScreen)
  //   "album"       → album (LibraryAlbumsScreen)
  //   "ep"          → also shows in albums view
  //   "single"      → also shows in albums view
  //   "compilation" → also shows in albums view
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

      // The server returns 201 Created on success
      _log('← ${response.statusCode} Created');

      final data = response.data!['data'] as Map<String, dynamic>;
      final created = PlaylistModel.fromJson(data);

      _log('← New playlist ID: ${created.id}  name: "${created.name}"');
      _log('✅ Playlist created successfully — verify in DB at playlist_id: ${created.id}');

      return created;
    } on DioException catch (e) {
      _logError('createPlaylist("$name") failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── UPDATE: Playlist Metadata + Optional Cover Image ────────
  // Endpoint: PATCH /playlists/{id}
  // Content-Type: multipart/form-data (because of the image)
  //
  // Called by: EditPlaylistSheet._onSave()
  //
  // Why multipart? Because we may be uploading a binary image file
  // alongside text fields. Regular JSON can't carry binary data.
  // ============================================================
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    String? name,
    bool? isPublic,
    String? description,
    File? coverImage,       // null = don't change the cover
    bool removeCover = false, // true = explicitly delete the cover
    String? subtype,
    String? releaseDate,    // format: "2026-03-06"
    String? genreId,
  }) async {
    // Build the form fields map — only include fields the caller passed
    final fields = <String, dynamic>{};
    if (name != null) fields['name'] = name;
    if (isPublic != null) fields['is_public'] = isPublic;
    if (description != null) fields['description'] = description;
    if (subtype != null) fields['subtype'] = subtype;
    if (releaseDate != null) fields['release_date'] = releaseDate;
    if (genreId != null) fields['genre_id'] = genreId;
    if (removeCover) fields['remove_cover_image'] = true;

    // If a new cover image file was provided, attach it as a
    // binary multipart file. Dio handles the encoding automatically.
    if (coverImage != null) {
      _log('Attaching cover image: ${coverImage.path}');
      fields['cover_image'] = await MultipartFile.fromFile(
        coverImage.path,
        filename: 'cover.jpg', // filename hint for the server
      );
    }

    _log('→ PATCH /playlists/$playlistId  fields: ${fields.keys.toList()}');

    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/playlists/$playlistId',
        // FormData.fromMap converts the map (including files) into
        // a proper multipart/form-data body
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
  // ── DELETE: Playlist ─────────────────────────────────────────
  // Endpoint: DELETE /playlists/{id}
  //
  // Called by: PlaylistOptionsSheet "Delete" button
  //
  // Returns: nothing (void). On success the server returns 200
  //          with { "data": { "success": true } }
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
  // ── ADD TRACK to Playlist ────────────────────────────────────
  // Endpoint: POST /playlists/{id}/tracks
  // Body: { "track_id": "uuid", "position": 1 (optional) }
  //
  // Called by: Add track flow (from search/suggestions)
  //
  // If position is null, the server appends the track to the end.
  // If position is provided, it inserts and shifts other tracks.
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
      // 409 means "track already in playlist" — not a fatal error
      if (e.response?.statusCode == 409) {
        _log('⚠️ Track $trackId already exists in playlist $playlistId (409)');
        return; // treat as success — no-op
      }
      _logError('addTrackToPlaylist failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── REMOVE TRACK from Playlist ──────────────────────────────
  // Endpoint: DELETE /playlists/{id}/tracks/{track_id}
  //
  // Called by: EditPlaylistSheet swipe-to-delete on tracks
  //
  // After deletion, the server re-normalises positions (1..N, no gaps).
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
  // ── REORDER TRACKS in Playlist ──────────────────────────────
  // Endpoint: PATCH /playlists/{id}/tracks/reorder
  // Body: { "items": [ { "track_id": "...", "position": 1 }, ... ] }
  //
  // Called by: EditPlaylistSheet drag-to-reorder
  //
  // IMPORTANT: You must send the FULL list of all tracks with
  //            their new positions — not just the moved one.
  //            Positions must start at 1 with no gaps.
  // ============================================================
  Future<void> reorderPlaylistTracks({
    required String playlistId,
    required List<String> orderedTrackIds, // ordered from position 1..N
  }) async {
    // Build the items array: [{ track_id: "...", position: 1 }, ...]
    final items = orderedTrackIds
        .asMap()
        .entries
        .map((entry) => {
              'track_id': entry.value,
              'position': entry.key + 1, // +1 because positions are 1-based
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
  // ── ENGAGEMENT: Like / Unlike ────────────────────────────────
  // POST /playlists/{id}/like     → like
  // DELETE /playlists/{id}/like   → unlike
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
  // ── ENGAGEMENT: Repost / Remove Repost ──────────────────────
  // POST /playlists/{id}/repost     → repost
  // DELETE /playlists/{id}/repost   → remove repost
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
  // ── STATIONS: Fetch List ─────────────────────────────────────
  // Endpoint: GET /home/stations
  //
  // Returns artist-based radio stations. These look like playlists
  // in the UI but are generated dynamically by the backend.
  //
  // For authenticated users: stations based on followed artists
  // For unauthenticated:     top 10 most-followed artists globally
  // ============================================================
  Future<List<PlaylistEntity>> fetchStations({int limit = 10}) async {
    _log('→ GET /home/stations  limit=$limit');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/home/stations',
        queryParameters: {'limit': limit},
      );

      _log('← ${response.statusCode}');

      // Response shape: { "data": [ { station object }, ... ] }
      final data = response.data!['data'] as List<dynamic>;
      _log('← Got ${data.length} stations');

      return StationModel.fromJsonList(data);
    } on DioException catch (e) {
      _logError('fetchStations() failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── STATIONS: Fetch Tracks ───────────────────────────────────
  // Endpoint: GET /home/stations/{artist_id}/tracks
  //
  // Returns the dynamically generated track list for a station.
  // The stationId here is actually the seed artist's user_id.
  //
  // NOTE: The API returns FeedTrack objects (not PlaylistTrackListItem),
  //       so we map them to PlaylistTrack here.
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

      // Response shape:
      // { "data": { "station": {...}, "tracks": [ {FeedTrack}, ... ] } }
      final data = response.data!['data'] as Map<String, dynamic>;
      final trackList = data['tracks'] as List<dynamic>;

      _log('← Got ${trackList.length} station tracks');

      // FeedTrack has a different shape than PlaylistTrackListItem
      // We map it manually here
      return _mapFeedTracksToPlaylistTracks(trackList);
    } on DioException catch (e) {
      _logError('fetchStationTracks($artistId) failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── RECOMMENDATIONS: Tracks for "Add to Playlist" suggestions
  // Endpoint: GET /feed/trending or /home/mixes/{id}/tracks
  //
  // Used in the "add tracks" search sheet to suggest tracks
  // the user might want to add.
  //
  // For simplicity, we use the trending endpoint.
  // The recommendation system (M7.5) will refine this later.
  // ============================================================
  Future<List<PlaylistTrack>> fetchRecommendedTracks({int limit = 20}) async {
    _log('→ GET /feed/trending  limit=$limit (for track suggestions)');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/feed/trending',
        queryParameters: {'limit': limit},
      );

      _log('← ${response.statusCode}');

      final data = response.data!['data'] as List<dynamic>;
      _log('← Got ${data.length} recommended tracks');

      // Trending tracks are FeedTrack objects — map them
      return _mapFeedTracksToPlaylistTracks(data, startPosition: 1);
    } on DioException catch (e) {
      _logError('fetchRecommendedTracks() failed', e);
      rethrow;
    }
  }

  // ============================================================
  // ── INTERNAL HELPER: Map FeedTrack JSON → PlaylistTrack ─────
  //
  // FeedTrack JSON shape (from /feed and /home endpoints):
  // {
  //   "id": "uuid",          ← note: "id" not "track_id"
  //   "title": "string",
  //   "artist": {
  //     "id": "uuid",
  //     "display_name": "string",
  //     "avatar": "url"
  //   },
  //   "duration": 210,
  //   "cover_url": "url",    ← note: "cover_url" not "cover_image"
  //   ...
  // }
  //
  // This is different from PlaylistTrackListItem, which uses:
  //   "track_id", "cover_image", "artist_name"
  // ============================================================
  List<PlaylistTrack> _mapFeedTracksToPlaylistTracks(
    List<dynamic> rawList, {
    int startPosition = 1,
  }) {
    return rawList.asMap().entries.map((entry) {
      final index = entry.key;
      final json = entry.value as Map<String, dynamic>;

      final artist = json['artist'] as Map<String, dynamic>? ?? {};

      return PlaylistTrack(
        id: json['id'] as String,
        title: json['title'] as String,
        artistName: artist['display_name'] as String? ?? 'Unknown Artist',
        duration: Duration(seconds: json['duration'] as int? ?? 0),
        playCount: json['play_count'] as int? ?? 0,
        position: startPosition + index,
        coverUrl: json['cover_url'] as String?,
        isUnavailable: false,
      );
    }).toList();
  }

  // ============================================================
  // ── LOGGING HELPERS ──────────────────────────────────────────
  // All datasource logs start with [DATASOURCE] so you can
  // filter them in your console with: flutter logs | grep DATASOURCE
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
    // The response body often has the specific error code from the API,
    // e.g.: { "error": { "code": "PLAYLIST_NOT_FOUND", "message": "..." } }
  }
}