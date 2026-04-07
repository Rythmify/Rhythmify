// import '../../domain/entities/collection_type.dart';
// import '../../domain/entities/playlist_entity.dart';
// import '../../domain/entities/playlist_track.dart';
// import '../../domain/entities/station_entity.dart';

// // ═══════════════════════════════════════════════════════════════════════════
// // PlaylistTrackItemModel
// // ═══════════════════════════════════════════════════════════════════════════

// /// Maps the `PlaylistTrackListItem` API schema to [PlaylistTrackItem].
// ///
// /// Used when deserialising `GET /playlists/{id}/tracks`.
// class PlaylistTrackItemModel {
//   const PlaylistTrackItemModel._();

//   static PlaylistTrack fromJson(Map<String, dynamic> json) {
//     return PlaylistTrack(
//       trackId: json['track_id'] as String,
//       position: json['position'] as int,
//       addedAt: DateTime.parse(json['added_at'] as String),
//       title: json['title'] as String,
//       artistName: json['artist_name'] as String,
//       artistId: json['artist_id'] as String,
//       isPublic: json['is_public'] as bool? ?? true,
//       duration: json['duration'] as int?,
//       coverImageUrl: json['cover_image'] as String?,
//       deletedAt: json['deleted_at'] != null
//           ? DateTime.tryParse(json['deleted_at'] as String)
//           : null,
//     );
//   }

//   static List<PlaylistTrackItem> fromJsonList(List<dynamic> jsonList) {
//     return jsonList
//         .cast<Map<String, dynamic>>()
//         .map(fromJson)
//         .toList();
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // StationModel
// // ═══════════════════════════════════════════════════════════════════════════

// /// Maps the `Station` API schema from `GET /home/stations` to [StationEntity].
// ///
// /// Also produces a [PlaylistEntity] shell with [CollectionType.station] so
// /// the shared [PlaylistDetailScreen] can consume it without a type switch.
// class StationModel {
//   const StationModel._();

//   static StationEntity fromJson(Map<String, dynamic> json) {
//     final seedArtist = json['seed_artist'] as Map<String, dynamic>? ?? {};
//     return StationEntity(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       seedArtistId: seedArtist['user_id'] as String? ?? '',
//       seedArtistDisplayName: seedArtist['display_name'] as String? ?? '',
//       seedArtistAvatarUrl: seedArtist['profile_picture'] as String?,
//       coverImageUrl: json['cover_image'] as String?,
//       trackCount: json['track_count'] as int? ?? 0,
//     );
//   }

//   /// Converts a [StationEntity] to a [PlaylistEntity] with
//   /// [CollectionType.station] set. This lets [PlaylistDetailScreen] use a
//   /// single entity type without a type check in the screen itself.
//   static PlaylistEntity toPlaylistEntity(StationEntity station) {
//     return PlaylistEntity(
//       id: station.id,
//       ownerUserId: station.seedArtistId,
//       name: station.name,
//       slug: station.id,
//       isPublic: true,
//       collectionType: CollectionType.station,
//       trackCount: station.trackCount,
//       likeCount: 0,
//       repostCount: 0,
//       createdAt: DateTime.now(),
//       coverImageUrl: station.coverImageUrl,
//       seedArtistId: station.seedArtistId,
//       seedArtistName: station.seedArtistDisplayName,
//       seedArtistAvatarUrl: station.seedArtistAvatarUrl,
//     );
//   }

//   static List<StationEntity> fromJsonList(List<dynamic> jsonList) {
//     return jsonList
//         .cast<Map<String, dynamic>>()
//         .map(fromJson)
//         .toList();
//   }
// }