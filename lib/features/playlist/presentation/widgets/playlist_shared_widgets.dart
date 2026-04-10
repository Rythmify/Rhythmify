// ============================================================
// SHARED PLAYLIST WIDGETS
// ============================================================
// These small widgets are used by multiple screens.
// Keeping them here means each screen file stays under 400 LOC.
// ============================================================

import 'package:flutter/material.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import 'dart:io';

// ════════════════════════════════════════════════════════════
// PlaylistCoverImage
// ════════════════════════════════════════════════════════════
/// Shows the playlist cover art, or the SoundCloud waveform placeholder
/// if there's no cover. The [size] parameter controls width and height.
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

  /// Decides whether to use Image.file or Image.network
  /// based on whether the URL is a local file path or a remote URL.
  Widget _buildCoverImage(String url) {
    // Local file paths start with / on iOS/Android
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Placeholder(playlist: playlist),
      );
    }
    // Remote URL
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _Placeholder(playlist: playlist),
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

// ════════════════════════════════════════════════════════════
// TrackTileInPlaylist
// ════════════════════════════════════════════════════════════
/// One track row as shown in the playlist detail screen (Images 1 & 2).
/// Shows: cover · title · artist · play count · duration · like icon
///
/// This is DIFFERENT from your partner's TrackCard — that one is used
/// in feeds and search. This one is used only inside playlists.
class TrackTileInPlaylist extends StatelessWidget {
  const TrackTileInPlaylist({
    super.key,
    required this.track,
    required this.onTap,
    this.trailingWidget,
  });

  final PlaylistTrack track;
  final VoidCallback onTap;

  /// Optional widget on the right: could be an [+] add button,
  /// a drag handle, or a red [−] remove button.
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: track.isUnavailable ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Cover art
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                width: 60,
                height: 60,
                child: track.coverUrl != null
                    ? Image.network(track.coverUrl!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Title + artist + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: track.isUnavailable
                          ? Colors.grey[600]
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (track.artistName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      track.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Stats row: play count · duration · like heart
                  if (track.isUnavailable)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          track.formattedPlayCount,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' · ${track.formattedDuration}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (track.isLiked) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFFF5500),
                            size: 12,
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
}

// ════════════════════════════════════════════════════════════
// BottomSheetHandle
// ════════════════════════════════════════════════════════════
/// The small grey pill at the top of every bottom sheet.
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

// ════════════════════════════════════════════════════════════
// OptionSheetTile
// ════════════════════════════════════════════════════════════
/// One row in the ··· options bottom sheet (Image 4).
/// Shows an icon + label, calls onTap when pressed.
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
