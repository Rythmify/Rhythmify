// ============================================================
// FILE: lib/features/playlist/data/models/station_model.dart
// ============================================================

import '../../domain/entities/playlist_entity.dart';

class StationModel {
  static PlaylistEntity fromJson(Map<String, dynamic> json) {
    _debugPrint('RAW station JSON: $json');

    final seedArtist = json['seed_artist'] as Map<String, dynamic>? ?? {};
    final artistId = seedArtist['user_id'] as String? ?? '';
    final artistName = seedArtist['display_name'] as String? ?? 'Unknown Artist';
    final stationId = json['id'] as String;

    final entity = PlaylistEntity(
      // Stations use "id" not "playlist_id"
      id: stationId,

      name: json['name'] as String,

      // The seed artist is the "owner" of the station conceptually
      ownerName: artistName,

      // Your entity calls this "ownerId"
      ownerId: artistId,

      isPublic: true, // stations are always public

      type: PlaylistType.station,

      trackCount: json['track_count'] as int? ?? 0,

      totalDuration: Duration.zero,

      createdAt: DateTime.now(), // stations have no creation date from the API

      coverUrl: json['cover_image'] as String?,

      description: 'Radio station based on $artistName\'s music',

      // Stations expose the seed artist name — store it here
      seedArtistName: artistName,
    );

    _debugPrint(
      'Parsed station: "${entity.name}"  '
      'artist: $artistName  '
      'tracks: ${entity.trackCount}  '
      'cover: ${entity.coverUrl ?? "none"}',
    );

    return entity;
  }

  static List<PlaylistEntity> fromJsonList(List<dynamic> list) {
    _debugPrint('Parsing ${list.length} stations...');
    return list.cast<Map<String, dynamic>>().map(fromJson).toList();
  }

  static void _debugPrint(String message) {
    // ignore: avoid_print
    print('[STATION MODEL] $message');
  }
}