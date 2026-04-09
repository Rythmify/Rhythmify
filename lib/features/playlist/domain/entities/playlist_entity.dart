// lib/features/playlist/domain/entities/playlist_entity.dart

enum PlaylistType { playlist, album, station }

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
    this.seedTrackTitle,
    this.seedArtistName,
    this.releaseYear, // NEW — used by albums: shows "2026 · Album" in header
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
  final String? seedTrackTitle;
  final String? seedArtistName;
  final String? releaseYear; // NEW

  // ── Label helpers ──────────────────────────────────────────────────────────

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

  String get formattedDuration {
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  /// Used in the Library list tile: "Playlist · 3 tracks · 9:25"
  String get subtitleLine =>
      '$typeLabel · $trackCount ${trackCount == 1 ? 'track' : 'tracks'} · $formattedDuration';

  /// NEW — used in the detail screen header. Each type shows differently:
  ///
  /// Playlist → "Playlist · 3 tracks · 9:25"
  /// Album    → "2026 · Album"
  /// Station  → "Artist Station · 2:27:08 · 50 tracks"
  String get detailSubtitle {
    switch (type) {
      case PlaylistType.album:
        final year = releaseYear ?? createdAt.year.toString();
        return '$year · Album';
      case PlaylistType.station:
        return 'Artist Station · $formattedDuration · $trackCount tracks';
      case PlaylistType.playlist:
        return subtitleLine;
    }
  }

  // ── copyWith ───────────────────────────────────────────────────────────────

  PlaylistEntity copyWith({
    String? name,
    bool? isPublic,
    String? description,
    String? coverUrl,
    int? trackCount,
    Duration? totalDuration,
    bool? isLiked,
    PlaylistType? type, // NEW — needed for convert operations
    String? seedArtistName, // NEW — needed for convert to station
    String? releaseYear, // NEW — needed for convert to album
    bool clearCover = false,
  }) {
    return PlaylistEntity(
      id: id,
      name: name ?? this.name,
      ownerName: ownerName,
      ownerId: ownerId,
      isPublic: isPublic ?? this.isPublic,
      type: type ?? this.type,
      trackCount: trackCount ?? this.trackCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt,
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      description: description ?? this.description,
      likeCount: likeCount,
      repostCount: repostCount,
      isLiked: isLiked ?? this.isLiked,
      seedTrackTitle: seedTrackTitle,
      seedArtistName: seedArtistName ?? this.seedArtistName,
      releaseYear: releaseYear ?? this.releaseYear,
    );
  }
}
