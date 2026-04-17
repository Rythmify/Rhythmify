// lib/features/playlist/data/models/playlist_track_model.dart

import '../../domain/entities/playlist_track.dart';

class PlaylistTrackModel {
  static PlaylistTrack fromJson(Map<String, dynamic> json) {
    _debugPrint('RAW track JSON: $json');

    final durationSeconds = json['duration'] as int? ?? 0;
    final duration = Duration(seconds: durationSeconds);

    final isUnavailable =
        json['is_public'] == false || json['deleted_at'] != null;

    final track = PlaylistTrack(
      id: json['track_id'] as String,
      title: json['title'] as String,
      artistName: json['artist_name'] as String,
      duration: duration,
      playCount: 0,
      position: json['position'] as int,
      coverUrl: json['cover_image'] as String?,
      isUnavailable: isUnavailable,
    );

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

  static List<PlaylistTrack> fromJsonList(List<dynamic> list) {
    _debugPrint('Parsing ${list.length} tracks from response...');

    // Handle empty list — new playlists have 0 tracks, this is valid
    if (list.isEmpty) {
      _debugPrint('Empty track list — playlist has no tracks yet');
      return [];
    }

    final tracks = list.cast<Map<String, dynamic>>().map(fromJson).toList();

    // Sort by position
    tracks.sort((a, b) => a.position.compareTo(b.position));

    // Safe first-element log — only runs when list is non-empty
    _debugPrint(
      'Tracks sorted. First: "${tracks.first.title}"  '
      'Last: "${tracks.last.title}"',
    );

    return tracks;
  }

  static void _debugPrint(String message) {
    // ignore: avoid_print
    print('[TRACK MODEL] $message');
  }
}