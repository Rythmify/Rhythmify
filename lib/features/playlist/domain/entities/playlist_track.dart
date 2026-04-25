// lib/features/playlist/domain/entities/playlist_track.dart
//
// Lightweight track model used inside playlist UI.
// Carries only what the playlist screens need to render a row.
// [fromTrack] converts a full [Track] entity into this model.
// [trackId] holds a reference back to the original [Track] so the
// player can receive full entities when the user taps a row.

library;

import '../../../../core/domain/entities/track.dart';

class PlaylistTrack {
  const PlaylistTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.duration,
    required this.playCount,
    required this.position,
    this.trackId,
    this.coverUrl,
    this.isLiked = false,
    this.isUnavailable = false,
    this.addedAt, // ← NEW: mapped from added_at in backend response
  });

  final String id;

  /// Reference back to the real Track.id for player lookup.
  /// Same as [id] in most cases — diverges only if duplicates exist.
  final String? trackId;

  final String title;
  final String artistName;
  final Duration duration;
  final int playCount;

  /// 1-based position in the playlist.
  /// 0 means not yet in a playlist (suggestion tracks).
  final int position;

  final String? coverUrl;
  final bool isLiked;

  /// True when the track is geo-restricted or removed from the platform.
  /// Shows a pin icon + "Not available" in the UI.
  final bool isUnavailable;
  final DateTime? addedAt; // ← NEW

  // ── Formatted helpers ──────────────────────────────────────────────────────

  String get formattedDuration {
    final m = duration.inMinutes;
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    }
    if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    }
    return '$playCount';
  }
  // ── copyWith ────────────────────────────────────────────────────────────────

  PlaylistTrack copyWith({int? position, bool? isLiked}) {
    return PlaylistTrack(
      id: id,
      trackId: trackId,
      title: title,
      artistName: artistName,
      duration: duration,
      playCount: playCount,
      position: position ?? this.position,
      coverUrl: coverUrl,
      isLiked: isLiked ?? this.isLiked,
      isUnavailable: isUnavailable,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // ── Track integration ───────────────────────────────────────────────────────

  /// Creates a [PlaylistTrack] from M13's [Track] entity.
  /// [position] is 1-based; pass 0 for suggestion tracks.
  factory PlaylistTrack.fromTrack(Track track, {int position = 0}) {
    return PlaylistTrack(
      id: track.id,
      trackId: track.id,
      title: track.title,
      artistName: track.artist,
      duration: track.duration,
      playCount: track.playCount,
      position: position,
      coverUrl: track.artworkUrl,
      isLiked: track.isLiked,
      isUnavailable: false,
      addedAt: null,
    );
  }
}
