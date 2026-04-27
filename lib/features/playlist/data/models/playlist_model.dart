// lib/features/playlist/data/models/playlist_model.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/playlist_entity.dart';

class PlaylistModel {
  static PlaylistEntity fromJson(
    Map<String, dynamic> json, {
    bool isOwned = false,
  }) {
    debugPrintPlaylist('RAW JSON received: $json');

    final subtype = json['subtype'] as String? ?? 'playlist';

    // KEY FIX: also read the top-level 'type' field from the backend.
    // The backend returns type: "track_radio" for track radio playlists
    // even when subtype is "playlist". This is the reliable signal.
    final typeField = json['type'] as String? ?? '';

    final playlistType = _typeFromSubtype(subtype);

    // releaseYear parsed as int? from release_date string
    final releaseDateStr = json['release_date'] as String?;
    final releaseYear = (releaseDateStr != null && releaseDateStr.length >= 4)
        ? int.tryParse(releaseDateStr.substring(0, 4))
        : null;

    // isGeneratedMix: from subtype
    final isGeneratedMix = subtype == 'auto_generated' ||
        subtype == 'curated_daily' ||
        subtype == 'curated_weekly' ||
        subtype == 'genre_trending';

    // isTrackRadio: from backend 'type' field OR subtype
    // Backend returns type: "track_radio" — this is the reliable signal
    final isTrackRadio = typeField == 'track_radio' ||
        subtype == 'track_radio';

    final entity = PlaylistEntity(
      id: json['playlist_id'] as String,
      name: json['name'] as String,
      ownerName: '',
      ownerId: json['owner_user_id'] as String,
      isPublic: json['is_public'] as bool? ?? true,
      type: playlistType,
      trackCount: (json['track_count'] as num?)?.toInt() ?? 0,
      totalDuration: Duration.zero,
      createdAt: DateTime.parse(json['created_at'] as String),
      coverUrl: json['cover_image'] as String?,
      description: json['description'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked_by_me'] as bool? ?? false,
      repostCount: (json['repost_count'] as num?)?.toInt() ?? 0,
      releaseYear: releaseYear,
      isOwned: isOwned,
      isGeneratedMix: isGeneratedMix,
      isTrackRadio: isTrackRadio,
    );

    debugPrintPlaylist(
      'Parsed → name: "${entity.name}"  '
      'id: ${entity.id}  '
      'type: ${entity.type}  '
      'subtype: $subtype  '
      'typeField: $typeField  '
      'isLiked: ${entity.isLiked}  '
      'isOwned: ${entity.isOwned}  '
      'isGeneratedMix: ${entity.isGeneratedMix}  '
      'isTrackRadio: ${entity.isTrackRadio}  '
      'tracks: ${entity.trackCount}  '
      'cover: ${entity.coverUrl ?? "none"}',
    );

    return entity;
  }

  static PlaylistType _typeFromSubtype(String subtype) {
    switch (subtype) {
      case 'album':
      case 'ep':
      case 'single':
      case 'compilation':
        return PlaylistType.album;
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

  static List<PlaylistEntity> fromJsonListOwned(List<dynamic> list) {
    debugPrintPlaylist('Parsing list of ${list.length} owned playlists...');
    return list
        .cast<Map<String, dynamic>>()
        .map((json) => fromJson(json, isOwned: true))
        .toList();
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
    debugPrint('[PLAYLIST MODEL] $message');
  }
}