import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

// ===================
//  TRACK CARD WIDGET
// ===================

class TrackCard extends ConsumerWidget {
  final TrackSummary track;

  const TrackCard({super.key, required this.track});

  // --- Formatting Helpers ---
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read our real player state
    final playerState = ref.watch(playerStateProvider);
    final currentPlayingId = playerState.currentTrack?.id;
    final isPlaying = playerState.status == PlayerStatus.playing;

    final isThisTrackLoaded = currentPlayingId == track.id;

    return InkWell(
      onTap: () {
        if (isThisTrackLoaded) {
          ref.read(playerStateProvider.notifier).togglePlayPause();
        } else {
          ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Artwork Image (Rounded Square)
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Image.asset(
                track.artworkUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                // Fallback icon in case the mock image isn't in the assets folder yet
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 65, height: 56, color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
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
                  const SizedBox(height: 2),
                  
                  // Artist
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 3. Bottom Status Row (Dynamic)
                  isThisTrackLoaded
                      ? _buildPlayingState(isPlaying)
                      : _buildStatsState(track),
                ],
              ),
            ),

            // 4. Trailing More Icon
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                // Open bottom sheet in the future
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets for the 3rd Row ---

  Widget _buildPlayingState(bool isPlaying) {
    return Row(
      children: [
        Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          color: isPlaying ? AppTheme.primaryBrand : Colors.grey,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          isPlaying ? 'Now Playing' : 'Paused',
          style: TextStyle(color:isPlaying ? AppTheme.primaryBrand : Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatsState(TrackSummary track) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.play_arrow, color: Colors.grey, size: 16),
        const SizedBox(width: 2),
        Text(
          _formatCount(track.playCount),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('•', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Text(
          _formatDuration(track.duration.inSeconds),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        if (track.isLiked) ...[
          const SizedBox(width: 8),
          const Icon(Icons.favorite, color: AppTheme.primaryBrand , size: 14),
        ]
      ],
    );
  }
}