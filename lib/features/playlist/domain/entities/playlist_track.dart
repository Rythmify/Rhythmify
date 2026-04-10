// ============================================================
// PlaylistTrack
// ============================================================

import '../../../../core/domain/entities/track.dart';

class PlaylistTrack {
  const PlaylistTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.duration,
    required this.playCount,
    required this.position,
    this.trackId,          // ← original Track.id for player lookup
    this.coverUrl,
    this.isLiked = false,
    this.isUnavailable = false,
  });

  final String id;
  final String? trackId;       // ← keep a reference back to the real Track
  final String title;
  final String artistName;
  final Duration duration;
  final int playCount;

  /// 1-based position in the playlist.
  /// 0 means "not in a playlist yet" (suggestion tracks).
  final int position;

  final String? coverUrl;
  final bool isLiked;

  /// True when geo-restricted or removed from the platform.
  final bool isUnavailable;

  // ── Formatters ─────────────────────────────────────────────

  /// "3:31", "1:10", etc.
  String get formattedDuration {
    final m = duration.inMinutes;
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// "99K", "1.9M", "41", etc.
  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    }
    if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    }
    return '$playCount';
  }

  // ── copyWith ───────────────────────────────────────────────

  PlaylistTrack copyWith({int? position, bool? isLiked}) {
    return PlaylistTrack(
      id:           id,
      trackId:      trackId,       // ← preserved
      title:        title,
      artistName:   artistName,
      duration:     duration,
      playCount:    playCount,
      position:     position ?? this.position,
      coverUrl:     coverUrl,
      isLiked:      isLiked ?? this.isLiked,
      isUnavailable: isUnavailable,
    );
  }

  // ── Track integration ──────────────────────────────────────

  /// Creates a PlaylistTrack from Track entity.
  /// [position] is 1-based; pass 0 for suggestion tracks.
  factory PlaylistTrack.fromTrack(Track track, {int position = 0}) {
    return PlaylistTrack(
      id:          track.id,
      trackId:     track.id,    // ← same for now; diverges when duplicates exist
      title:       track.title,
      artistName:  track.artist,
      duration:    track.duration,
      playCount:   track.playCount,
      position:    position,
      coverUrl:    track.artworkUrl,   // getter: coverImage ?? ''
      isLiked:     track.isLiked,
      isUnavailable: false,
    );
  }
}