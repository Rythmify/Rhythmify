// ============================================================
// FILE: lib/features/playlist/data/models/playlist_model.dart
// ============================================================

import '../../domain/entities/playlist_entity.dart';

class PlaylistModel {
  static PlaylistEntity fromJson(Map<String, dynamic> json) {
    debugPrintPlaylist('RAW JSON received: $json');

    final subtype = json['subtype'] as String? ?? 'playlist';
    final playlistType = _typeFromSubtype(subtype);
    final releaseYear = (json['release_date'] as String?)?.substring(0, 4);

    final entity = PlaylistEntity(
      // The API sends "playlist_id" — we read that key and put it in "id"
      id: json['playlist_id'] as String,

      name: json['name'] as String,

      // The API doesn't return the owner's display name inside the playlist
      // object, so we leave ownerName empty for now.
      // If you need it displayed, fetch it separately from the auth provider.
      ownerName: '',

      // Your entity calls this "ownerId" — the API calls it "owner_user_id"
      ownerId: json['owner_user_id'] as String,

      isPublic: json['is_public'] as bool? ?? true,

      type: playlistType,

      trackCount: json['track_count'] as int? ?? 0,

      // Not returned by the API — computed on the client from the track list
      totalDuration: Duration.zero,

      createdAt: DateTime.parse(json['created_at'] as String),

      // Optional fields — null-safe reads
      coverUrl: json['cover_image'] as String?,
      description: json['description'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      repostCount: json['repost_count'] as int? ?? 0,
      releaseYear: releaseYear,

      // NOTE: "slug" exists in the API response but NOT on your entity.
      // We simply ignore it — no field to map it to.
    );

    debugPrintPlaylist(
      'Parsed → name: "${entity.name}"  '
      'id: ${entity.id}  '
      'type: ${entity.type}  '
      'tracks: ${entity.trackCount}  '
      'cover: ${entity.coverUrl ?? "none"}',
    );

    return entity;
  }

  // Maps the API's subtype string to your PlaylistType enum
  static PlaylistType _typeFromSubtype(String subtype) {
    switch (subtype) {
      case 'album':
      case 'ep':
      case 'single':
      case 'compilation':
        return PlaylistType.album;
      case 'playlist':
      default:
        return PlaylistType.playlist;
    }
  }

  static List<PlaylistEntity> fromJsonList(List<dynamic> list) {
    debugPrintPlaylist('Parsing list of ${list.length} playlists...');
    return list.cast<Map<String, dynamic>>().map(fromJson).toList();
  }

  static Map<String, dynamic> toCreateJson({
    required String name,
    required bool isPublic,
    String subtype = 'playlist',
  }) {
    final body = {'name': name, 'is_public': isPublic, 'subtype': subtype};
    debugPrintPlaylist('toCreateJson → $body');
    return body;
  }

  static void debugPrintPlaylist(String message) {
    // ignore: avoid_print
    print('[PLAYLIST MODEL] $message');
  }
}
