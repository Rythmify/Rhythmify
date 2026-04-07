// import '../../domain/entities/collection_type.dart';
// import '../../domain/entities/playlist_entity.dart';

// /// Data model for the `Playlist` schema from the API.
// ///
// /// Responsible for one thing: converting raw JSON (from Dio responses) into
// /// a domain [PlaylistEntity]. No business logic lives here.
// ///
// /// Matches the `Playlist` OpenAPI schema:
// /// - `playlist_id`, `owner_user_id`, `name`, `slug`, `is_public`, `subtype`
// /// - `description`, `cover_image`, `release_date`, `genre_id`, `tags`
// /// - `track_count`, `like_count`, `repost_count`
// /// - `created_at`, `updated_at`
// ///
// /// The `secret_token` is included when the requester is the playlist owner.
// class PlaylistModel {
//   const PlaylistModel._();

//   /// Deserialises a raw JSON map from `GET /playlists/{id}` or
//   /// `POST /playlists` into a [PlaylistEntity].
//   static PlaylistEntity fromJson(Map<String, dynamic> json) {
//     final subtype = json['subtype'] as String?;
//     final collectionType = collectionTypeFromSubtype(subtype);

//     // Tags come as a list of tag objects with `name` field.
//     final rawTags = json['tags'] as List<dynamic>? ?? [];
//     final tags = rawTags
//         .map((t) => t is Map ? t['name'] as String? ?? '' : '')
//         .where((name) => name.isNotEmpty)
//         .toList();

//     return PlaylistEntity(
//       id: json['playlist_id'] as String,
//       ownerUserId: json['owner_user_id'] as String,
//       name: json['name'] as String,
//       slug: json['slug'] as String? ?? '',
//       isPublic: json['is_public'] as bool? ?? true,
//       collectionType: collectionType,
//       description: json['description'] as String?,
//       coverImageUrl: json['cover_image'] as String?,
//       releaseDate: json['release_date'] as String?,
//       genreId: json['genre_id'] as String?,
//       tags: tags,
//       trackCount: json['track_count'] as int? ?? 0,
//       likeCount: json['like_count'] as int? ?? 0,
//       repostCount: json['repost_count'] as int? ?? 0,
//       createdAt: DateTime.parse(json['created_at'] as String),
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'] as String)
//           : null,
//       secretToken: json['secret_token'] as String?,
//     );
//   }

//   /// Deserialises a list of playlist JSON objects (from `GET /playlists`).
//   static List<PlaylistEntity> fromJsonList(List<dynamic> jsonList) {
//     return jsonList
//         .cast<Map<String, dynamic>>()
//         .map(fromJson)
//         .toList();
//   }
// }