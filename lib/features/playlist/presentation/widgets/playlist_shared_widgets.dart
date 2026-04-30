// lib/features/playlist/presentation/widgets/playlist_shared_widgets.dart
/// This file contains reusable shared UI widgets used across playlist screens.
///
/// Features:
/// - Playlist cover image rendering
/// - Playlist track row widgets
/// - Generic track row widgets
/// - Shared bottom sheet handle
/// - Shared option sheet tile widget
/// - Placeholder image handling
///
/// Main Components:
/// - PlaylistCoverImage:
///     Displays playlist cover art or fallback placeholder.
///
/// - TrackTileInPlaylist:
///     Displays playlist track information.
///
/// - TrackTileFromTrack:
///     Displays a generic track row from a Track entity.
///
/// - BottomSheetHandle:
///     Reusable drag handle for modal sheets.
///
/// - OptionSheetTile:
///     Reusable option/action tile widget.
///
/// Dependencies:
/// - Cached network image package
/// - Playlist entities/models
/// - Track entity
/// - Shared app theme/utilities
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import 'dart:io';

// ════════════════════════════════════════════════════════════════════════════
// PlaylistCoverImage
// ════════════════════════════════════════════════════════════════════════════

class PlaylistCoverImage extends StatelessWidget {
  const PlaylistCoverImage({
    super.key,
    required this.playlist,
    required this.size,
    this.borderRadius = 4.0,
  });

  final PlaylistEntity playlist;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: playlist.coverUrl != null
            ? _buildCoverImage(playlist.coverUrl!)
            : _Placeholder(playlist: playlist),
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Placeholder(playlist: playlist),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, _) => _Placeholder(playlist: playlist),
      errorWidget: (_, _, _) => _Placeholder(playlist: playlist),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.playlist});
  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Icon(
          playlist.type == PlaylistType.station
              ? Icons.radio
              : playlist.type == PlaylistType.album
              ? Icons.album
              : Icons.queue_music,
          color: Colors.grey[600],
          size: 28,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TrackTileInPlaylist
// ════════════════════════════════════════════════════════════════════════════

class TrackTileInPlaylist extends StatelessWidget {
  const TrackTileInPlaylist({
    super.key,
    required this.track,
    required this.onTap,
    this.trailingWidget,
  });

  final PlaylistTrack track;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: track.isUnavailable ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Cover art ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: Colors.grey.shade700, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.5),
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: track.coverUrl != null && track.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: track.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _buildPlaceholder(),
                          errorWidget: (_, _, _) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Text column ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: track.isUnavailable
                          ? Colors.grey[600]
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (track.artistName.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      track.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 2),

                  // ── Stats / unavailable row ────────────────────────
                  if (track.isUnavailable)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          track.formattedPlayCount,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '•',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                        Text(
                          track.formattedDuration,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        // ── addedAt timestamp ───────────────────────
                        if (track.addedAt != null) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            timeAgo(track.addedAt!),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],

                        if (track.isLiked) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.favorite,
                            color: AppTheme.primaryBrand,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),

            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 65,
      height: 65,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.music_note, color: Colors.grey, size: 24),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TrackTileFromTrack
// ════════════════════════════════════════════════════════════════════════════

class TrackTileFromTrack extends StatelessWidget {
  const TrackTileFromTrack({
    super.key,
    required this.track,
    required this.onTap,
  });

  final Track track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minutes = track.duration.inMinutes;
    final seconds = (track.duration.inSeconds % 60).toString().padLeft(2, '0');
    final durationStr = '$minutes:$seconds';

    final playStr = track.playCount >= 1000000
        ? '${(track.playCount / 1000000).toStringAsFixed(1)}M'
        : track.playCount >= 1000
        ? '${(track.playCount / 1000).toStringAsFixed(1)}K'
        : '${track.playCount}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover art
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: Colors.grey.shade700, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.5),
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child:
                      track.coverImage != null && track.coverImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: track.coverImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _buildPlaceholder(),
                          errorWidget: (_, _, _) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + artist + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        playStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '•',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      Text(
                        durationStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (track.isLiked) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.favorite,
                          size: 14,
                          color: AppTheme.primaryBrand,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Options menu
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 24),
              onPressed: () => _showTrackOptions(context, track),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() => Container(
    width: 65,
    height: 65,
    color: const Color(0xFF2A2A2A),
    child: const Icon(Icons.music_note, color: Colors.grey, size: 24),
  );

  void _showTrackOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: track.coverImage != null
                          ? CachedNetworkImage(
                              imageUrl: track.coverImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: const Color(0xFF2A2A2A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          track.artist,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            OptionSheetTile(
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              icon: Icons.add_to_queue,
              label: 'Play last',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              icon: Icons.favorite_border,
              label: 'Like',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BottomSheetHandle
// ════════════════════════════════════════════════════════════════════════════

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// OptionSheetTile
// ════════════════════════════════════════════════════════════════════════════

class OptionSheetTile extends StatelessWidget {
  const OptionSheetTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
