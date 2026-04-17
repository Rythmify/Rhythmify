// ============================================================
// FILE: lib/features/playlist/data/models/playlist_track_model.dart
//
// PURPOSE: Translates the track JSON from GET /playlists/{id}/tracks
//          into your PlaylistTrack entity.
//
// STAGE: 1 of 7 — Models
//
// The API returns "PlaylistTrackListItem" objects that look like:
// {
//   "track_id": "uuid",
//   "position": 1,
//   "title": "Lift Me Up",
//   "duration": 214,            ← seconds
//   "cover_image": "https://...",
//   "is_public": true,
//   "deleted_at": null,
//   "artist_name": "DJ Nova",
//   "artist_id": "uuid"
// }
//
// HOW TO VERIFY: After fetchPlaylistTracks() runs, you should see
//   "[TRACK MODEL] Parsed track #1: Lift Me Up by DJ Nova (3:34)"
//   for each track in the console.
// ============================================================

import '../../domain/entities/playlist_track.dart';

class PlaylistTrackModel {
  // ----------------------------------------------------------
  // fromJson — converts one track JSON object → PlaylistTrack
  // ----------------------------------------------------------
  static PlaylistTrack fromJson(Map<String, dynamic> json) {
    // 🔍 DEBUG: Show the raw track data coming in
    _debugPrint('RAW track JSON: $json');

    final durationSeconds = json['duration'] as int? ?? 0;
    final duration = Duration(seconds: durationSeconds);

    // A track is "unavailable" if:
    //   1. It's private (is_public == false), OR
    //   2. It was deleted (deleted_at is not null)
    // Unavailable tracks show a greyed-out state in the UI
    final isUnavailable =
        json['is_public'] == false || json['deleted_at'] != null;

    final track = PlaylistTrack(
      // The track's own unique ID
      id: json['track_id'] as String,

      title: json['title'] as String,

      artistName: json['artist_name'] as String,

      duration: duration,

      // play_count is not returned in the playlist tracks endpoint
      // (you'd need to call GET /tracks/{id} for that)
      playCount: 0,

      // position is 1-based (first track = 1, not 0)
      position: json['position'] as int,

      coverUrl: json['cover_image'] as String?,

      isUnavailable: isUnavailable,
    );

    // 🔍 DEBUG: Show the parsed track in a readable format
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    _debugPrint(
      'Parsed track #${track.position}: "${track.title}" '
      'by ${track.artistName} '
      '($minutes:$seconds) '
      'unavailable: ${track.isUnavailable}',
    );

    return track;
  }

  // ----------------------------------------------------------
  // fromJsonList — converts a list of track JSON objects
  // ----------------------------------------------------------
  static List<PlaylistTrack> fromJsonList(List<dynamic> list) {
    _debugPrint('Parsing ${list.length} tracks from response...');
    final tracks = list.cast<Map<String, dynamic>>().map(fromJson).toList();

    // Sort by position just in case the server sends them out of order
    tracks.sort((a, b) => a.position.compareTo(b.position));
    _debugPrint('Tracks sorted by position. First: "${tracks.first.title}"');

    return tracks;
  }

  static void _debugPrint(String message) {
    // ignore: avoid_print
    print('[TRACK MODEL] $message');
  }
}