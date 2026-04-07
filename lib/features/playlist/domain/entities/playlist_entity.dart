// ============================================================
// PlaylistEntity
// ============================================================
// This is the data shape for a playlist (or album or station).
// It holds all the info you need to display a playlist card or
// the detail page. No HTTP, no Flutter, just pure Dart.
// ============================================================

/// Tells the UI what "kind" of collection this is.
/// The UI uses this to show different labels and minor UI tweaks.
enum PlaylistType {
  playlist, // Regular user-created playlist
  album,    // Artist album (same UI, different label)
  station,  // Auto-generated radio based on a track/artist
}

class PlaylistEntity {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerId,
    required this.isPublic,
    required this.type,
    required this.trackCount,
    required this.totalDuration,
    required this.createdAt,
    this.coverUrl,
    this.description,
    this.likeCount = 0,
    this.repostCount = 0,
    this.isLiked = false,
    // Station-only fields
    this.seedTrackTitle,
    this.seedArtistName,
  });

  final String id;
  final String name;
  final String ownerName;
  final String ownerId;
  final bool isPublic;
  final PlaylistType type;
  final int trackCount;
  final Duration totalDuration;
  final DateTime createdAt;
  final String? coverUrl;
  final String? description;
  final int likeCount;
  final int repostCount;
  final bool isLiked;

  // Only set when type == PlaylistType.station
  final String? seedTrackTitle;
  final String? seedArtistName;

  // ── Helper getters ──────────────────────────────────────────

  /// The label shown in the UI: "Playlist", "Album", or "Station"
  String get typeLabel {
    switch (type) {
      case PlaylistType.playlist:
        return 'Playlist';
      case PlaylistType.album:
        return 'Album';
      case PlaylistType.station:
        return 'Station';
    }
  }

  /// Formats the total duration like SoundCloud does:
  /// under 1 hour → "9:25", over 1 hour → "11:04:23"
  String get formattedDuration {
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  /// The subtitle line you see under the name in Image 6:
  /// "Playlist · 3 tracks · 9:25"
  String get subtitleLine =>
      '$typeLabel · $trackCount ${trackCount == 1 ? 'track' : 'tracks'} · $formattedDuration';

  // ── copyWith ─────────────────────────────────────────────────
  // Returns a new PlaylistEntity with some fields changed.
  // We use this instead of mutating, because Flutter state works
  // better with immutable objects.
  PlaylistEntity copyWith({
    String? name,
    bool? isPublic,
    String? description,
    String? coverUrl,
    int? trackCount,
    Duration? totalDuration,
    bool? isLiked,
    bool clearCover = false,
  }) {
    return PlaylistEntity(
      id: id,
      name: name ?? this.name,
      ownerName: ownerName,
      ownerId: ownerId,
      isPublic: isPublic ?? this.isPublic,
      type: type,
      trackCount: trackCount ?? this.trackCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt,
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      description: description ?? this.description,
      likeCount: likeCount,
      repostCount: repostCount,
      isLiked: isLiked ?? this.isLiked,
      seedTrackTitle: seedTrackTitle,
      seedArtistName: seedArtistName,
    );
  }
}