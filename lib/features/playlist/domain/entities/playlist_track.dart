// lib/features/playlist/domain/entities/playlist_track.dart

// Lightweight track model used inside playlist UI.
// Carries only what the playlist screens need to render a row.
// [fromTrack] converts a full [Track] entity into this model.
// [trackId] holds a reference back to the original [Track] so the
// player can receive full entities when the user taps a row.

/// This file defines the lightweight PlaylistTrack model used inside playlist
/// screens and playlist UI.
///
/// Purpose:
/// - Stores only the track information needed for playlist rendering
/// - Provides helper formatting methods
/// - Supports converting full Track entities into PlaylistTrack objects
///
/// Main Components:
/// - PlaylistTrack:
///     Lightweight playlist track model.
///
/// Features:
/// - Formatted duration helper
/// - Formatted play count helper
/// - Immutable updates using copyWith()
/// - Factory constructor for Track conversion
///
/// Methods:
/// - formattedDuration:
///     Returns track duration as mm:ss.
///
/// - formattedPlayCount:
///     Returns formatted play count string.
///
/// - copyWith():
///     Creates a modified copy of the track.
///
/// - PlaylistTrack.fromTrack():
///     Converts a Track entity into a PlaylistTrack.
///
/// Dependencies:
/// - Track entity
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
    this.addedAt,
    this.streamUrl,
    this.audioUrl,
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
  final DateTime? addedAt;
  final String? streamUrl;
  final String? audioUrl;

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

  PlaylistTrack copyWith({
    int? position,
    bool? isLiked,
    String? streamUrl,
    String? audioUrl,
  }) {
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
      addedAt: addedAt,
      streamUrl: streamUrl ?? this.streamUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  /// Converts this [PlaylistTrack] into a full [Track] entity.
  /// Used for player integration where full entities are required.
  Track toTrack() {
    return Track(
      id: id,
      userId: '', // placeholder, will be resolved in background if needed
      title: title,
      artist: artistName,
      audioUrl: (streamUrl ?? audioUrl) ?? '',
      streamUrl: streamUrl,
      duration: duration,
      createdAt: DateTime.now(),
      coverImage: coverUrl,
      isLiked: isLiked,
      playCount: playCount,
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
      streamUrl: track.streamUrl,
      audioUrl: track.audioUrl,
    );
  }
}
