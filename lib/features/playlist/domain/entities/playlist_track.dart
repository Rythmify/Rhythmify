// ============================================================
// PlaylistTrack
// ============================================================
// Represents one track row inside a playlist.
// This is different from your partner's Track entity — it's
// a lighter version that only carries what the playlist UI needs.
// ============================================================

class PlaylistTrack {
  const PlaylistTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.duration,
    required this.playCount,
    required this.position,
    this.coverUrl,
    this.isLiked = false,
    this.isUnavailable = false,
  });

  final String id;
  final String title;
  final String artistName;
  final Duration duration;
  final int playCount;

  /// 1-based position in the playlist. 0 means "not in a playlist yet"
  /// (used for suggestion tracks).
  final int position;

  final String? coverUrl;
  final bool isLiked;

  /// True when the track is geo-restricted or removed.
  /// SoundCloud shows a pin icon and "Not available" in this case.
  final bool isUnavailable;

  // ── Formatters ───────────────────────────────────────────────

  /// "3:31", "1:10", etc.
  String get formattedDuration {
    final m = duration.inMinutes;
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// "99K", "1.9M", "41", etc. — same as SoundCloud's display.
  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    }
    if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    }
    return '$playCount';
  }

  PlaylistTrack copyWith({
    int? position,
    bool? isLiked,
  }) {
    return PlaylistTrack(
      id: id,
      title: title,
      artistName: artistName,
      duration: duration,
      playCount: playCount,
      position: position ?? this.position,
      coverUrl: coverUrl,
      isLiked: isLiked ?? this.isLiked,
      isUnavailable: isUnavailable,
    );
  }
}