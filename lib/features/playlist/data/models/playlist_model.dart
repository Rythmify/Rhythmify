// lib/features/playlist/data/models/playlist_model.dart
//
// FIX: _typeFromSubtype now handles all generated playlist subtypes from the
// backend (auto_generated, curated_daily, curated_weekly, genre_trending,
// track_radio). These all map to PlaylistType.playlist so they render
// correctly in LibraryPlaylistsScreen.

import '../../domain/entities/playlist_entity.dart';

class PlaylistModel {
  static PlaylistEntity fromJson(Map<String, dynamic> json) {
    debugPrintPlaylist('RAW JSON received: $json');

    final subtype = json['subtype'] as String? ?? 'playlist';
    final playlistType = _typeFromSubtype(subtype);
    final releaseYear = (json['release_date'] as String?)?.substring(0, 4);

    final entity = PlaylistEntity(
      id: json['playlist_id'] as String,
      name: json['name'] as String,
      ownerName: '',
      ownerId: json['owner_user_id'] as String,
      isPublic: json['is_public'] as bool? ?? true,
      type: playlistType,
      trackCount: json['track_count'] as int? ?? 0,
      totalDuration: Duration.zero,
      createdAt: DateTime.parse(json['created_at'] as String),
      coverUrl: json['cover_image'] as String?,
      description: json['description'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked_by_me'] as bool? ?? false,
      repostCount: json['repost_count'] as int? ?? 0,
      releaseYear: releaseYear,
    );

    debugPrintPlaylist(
      'Parsed → name: "${entity.name}"  '
      'id: ${entity.id}  '
      'type: ${entity.type}  '
      'subtype: $subtype  '
      'isLiked: ${entity.isLiked}  '
      'tracks: ${entity.trackCount}  '
      'cover: ${entity.coverUrl ?? "none"}',
    );

    return entity;
  }

  /// Maps the API's subtype string to PlaylistType.
  ///
  /// Generated playlist types (auto_generated, curated_daily, curated_weekly,
  /// genre_trending, track_radio) all map to PlaylistType.playlist so they
  /// appear in the playlist library screen's Liked tab.
  static PlaylistType _typeFromSubtype(String subtype) {
    switch (subtype) {
      case 'album':
      case 'ep':
      case 'single':
      case 'compilation':
        return PlaylistType.album;
      // Generated types — render as playlist in library
      case 'auto_generated':
      case 'curated_daily':
      case 'curated_weekly':
      case 'genre_trending':
      case 'track_radio':
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