// import 'dart:io';

// import 'package:dio/dio.dart';

// import '../../domain/entities/playlist_entity.dart';
// import '../../domain/entities/playlist_track.dart';
// import '../../domain/entities/station_entity.dart';
// import '../models/playlist_model.dart';
// import '../models/playlist_track_model.dart';

// /// Remote datasource for all playlist, album, and station operations.
// ///
// /// All calls use [_dio] from the team-leader-created [ApiClient], which
// /// automatically attaches the Bearer token and handles token refresh.
// ///
// /// This class throws [DioException] on network/HTTP errors — the repository
// /// implementation catches and converts them to [Failure] types.
// class PlaylistRemoteDatasource {
//   const PlaylistRemoteDatasource(this._dio);

//   final Dio _dio;

//   // ── Create ──────────────────────────────────────────────────────────────

//   /// `POST /playlists`
//   Future<PlaylistEntity> createPlaylist({
//     required String name,
//     required bool isPublic,
//     required String subtype,
//   }) async {
//     final response = await _dio.post<Map<String, dynamic>>(
//       '/playlists',
//       data: {
//         'name': name,
//         'is_public': isPublic,
//         'subtype': subtype,
//       },
//     );
//     return PlaylistModel.fromJson(
//       response.data!['data'] as Map<String, dynamic>,
//     );
//   }

//   // ── Update ───────────────────────────────────────────────────────────────

//   /// `PATCH /playlists/{id}` — uses multipart/form-data per the API spec.
//   Future<PlaylistEntity> updatePlaylist({
//     required String playlistId,
//     String? name,
//     String? description,
//     bool? isPublic,
//     File? coverImage,
//     bool removeCover = false,
//     String? subtype,
//     String? releaseDate,
//     String? genreId,
//     List<String>? tags,
//   }) async {
//     final fields = <String, dynamic>{};
//     if (name != null) fields['name'] = name;
//     if (description != null) fields['description'] = description;
//     if (isPublic != null) fields['is_public'] = isPublic;
//     if (subtype != null) fields['subtype'] = subtype;
//     if (releaseDate != null) fields['release_date'] = releaseDate;
//     if (genreId != null) fields['genre_id'] = genreId;
//     if (removeCover) fields['remove_cover_image'] = true;
//     if (tags != null) {
//       for (int i = 0; i < tags.length; i++) {
//         fields['tags[$i]'] = tags[i];
//       }
//     }
//     if (coverImage != null) {
//       fields['cover_image'] = await MultipartFile.fromFile(
//         coverImage.path,
//         filename: 'cover.jpg',
//       );
//     }

//     final response = await _dio.patch<Map<String, dynamic>>(
//       '/playlists/$playlistId',
//       data: FormData.fromMap(fields),
//     );
//     return PlaylistModel.fromJson(
//       response.data!['data'] as Map<String, dynamic>,
//     );
//   }

//   // ── Delete ───────────────────────────────────────────────────────────────

//   /// `DELETE /playlists/{id}`
//   Future<void> deletePlaylist(String playlistId) async {
//     await _dio.delete<void>('/playlists/$playlistId');
//   }

//   // ── Fetch list ───────────────────────────────────────────────────────────

//   /// `GET /playlists?mine=true&filter=created|liked`
//   Future<List<PlaylistEntity>> fetchMyPlaylists({
//     String filter = 'created',
//     bool albumView = false,
//     int limit = 20,
//     int offset = 0,
//   }) async {
//     final response = await _dio.get<Map<String, dynamic>>(
//       '/playlists',
//       queryParameters: {
//         'mine': true,
//         'filter': filter,
//         'is_album_view': albumView,
//         'limit': limit,
//         'offset': offset,
//       },
//     );
//     final items =
//         response.data!['data']['items'] as List<dynamic>;
//     return PlaylistModel.fromJsonList(items);
//   }

//   // ── Fetch detail ─────────────────────────────────────────────────────────

//   /// `GET /playlists/{id}`
//   Future<PlaylistEntity> fetchPlaylistDetail({
//     required String playlistId,
//     String? secretToken,
//   }) async {
//     final response = await _dio.get<Map<String, dynamic>>(
//       '/playlists/$playlistId',
//       queryParameters: {
//         if (secretToken != null) 'secret_token': secretToken,
//         'include_tracks': false, // tracks fetched separately for pagination
//       },
//     );
//     return PlaylistModel.fromJson(
//       response.data!['data'] as Map<String, dynamic>,
//     );
//   }

//   // ── Fetch tracks ─────────────────────────────────────────────────────────

//   /// `GET /playlists/{id}/tracks`
//   Future<List<PlaylistTrackItem>> fetchPlaylistTracks({
//     required String playlistId,
//     String? secretToken,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     final response = await _dio.get<Map<String, dynamic>>(
//       '/playlists/$playlistId/tracks',
//       queryParameters: {
//         if (secretToken != null) 'secret_token': secretToken,
//         'page': page,
//         'limit': limit,
//       },
//     );
//     final tracks =
//         response.data!['data']['tracks'] as List<dynamic>;
//     return PlaylistTrackItemModel.fromJsonList(tracks);
//   }

//   // ── Track management ─────────────────────────────────────────────────────

//   /// `POST /playlists/{id}/tracks`
//   Future<void> addTrackToPlaylist({
//     required String playlistId,
//     required String trackId,
//     int? position,
//   }) async {
//     await _dio.post<void>(
//       '/playlists/$playlistId/tracks',
//       data: {
//         'track_id': trackId,
//         if (position != null) 'position': position,
//       },
//     );
//   }

//   /// `DELETE /playlists/{id}/tracks/{trackId}`
//   Future<void> removeTrackFromPlaylist({
//     required String playlistId,
//     required String trackId,
//   }) async {
//     await _dio.delete<void>('/playlists/$playlistId/tracks/$trackId');
//   }

//   /// `PATCH /playlists/{id}/tracks/reorder`
//   Future<void> reorderPlaylistTracks({
//     required String playlistId,
//     required List<String> orderedTrackIds,
//   }) async {
//     final items = orderedTrackIds
//         .asMap()
//         .entries
//         .map((e) => {'track_id': e.value, 'position': e.key + 1})
//         .toList();

//     await _dio.patch<void>(
//       '/playlists/$playlistId/tracks/reorder',
//       data: {'items': items},
//     );
//   }

//   // ── Engagement ────────────────────────────────────────────────────────────

//   /// `POST /playlists/{id}/like`
//   Future<void> likePlaylist(String playlistId) async {
//     await _dio.post<void>('/playlists/$playlistId/like');
//   }

//   /// `DELETE /playlists/{id}/like`
//   Future<void> unlikePlaylist(String playlistId) async {
//     await _dio.delete<void>('/playlists/$playlistId/like');
//   }

//   /// `POST /playlists/{id}/repost`
//   Future<void> repostPlaylist(String playlistId) async {
//     await _dio.post<void>('/playlists/$playlistId/repost');
//   }

//   /// `DELETE /playlists/{id}/repost`
//   Future<void> removePlaylistRepost(String playlistId) async {
//     await _dio.delete<void>('/playlists/$playlistId/repost');
//   }

//   // ── Stations ──────────────────────────────────────────────────────────────

//   /// `GET /home/stations`
//   Future<List<StationEntity>> fetchStations({
//     int limit = 10,
//     int offset = 0,
//   }) async {
//     final response = await _dio.get<Map<String, dynamic>>(
//       '/home/stations',
//       queryParameters: {'limit': limit, 'offset': offset},
//     );
//     final items = response.data!['data'] as List<dynamic>;
//     return StationModel.fromJsonList(items);
//   }

//   /// `GET /home/stations/{artistId}/tracks`
//   Future<List<PlaylistTrackItem>> fetchStationTracks({
//     required String artistId,
//     int limit = 50,
//     int offset = 0,
//   }) async {
//     final response = await _dio.get<Map<String, dynamic>>(
//       '/home/stations/$artistId/tracks',
//       queryParameters: {'limit': limit, 'offset': offset},
//     );
//     final tracks =
//         response.data!['data']['tracks'] as List<dynamic>;
//     return PlaylistTrackItemModel.fromJsonList(tracks);
//   }
// }
