import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';
import 'bottom_sheets/track_options_modal.dart';

/// [TrackCard] is a UI component that displays a summary of a track.
///
/// It provides information such as the track's title, artist, and playback stats,
/// and allows the user to interact with the track (e.g., play/pause).
///
/// Depends on [playerStateProvider].
class TrackCard extends ConsumerWidget {
  /// Track item rendered by this card.
  final Track track;

  /// Optional external tap callback.
  final VoidCallback? onTap;

  /// Whether to observe player state and show dynamic playback status.
  final bool observePlayerState;

  /// Creates a [TrackCard].
  const TrackCard({
    super.key,
    required this.track,
    this.onTap,
    this.observePlayerState = true,
  });

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
    final playerState = observePlayerState
        ? ref.watch(playerStateProvider)
        : const AppPlayerState();
    final currentPlayingId = playerState.currentTrack?.id;
    final isPlaying = playerState.status == PlayerStatus.playing;
    final isThisTrackLoaded =
        observePlayerState && currentPlayingId == track.id;

    return InkWell(
      key: Key('track_card_${track.id}_inkwell'),
      onTap: () {
        if (onTap != null) {
          onTap!();
          return;
        }
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: Colors.grey.shade700, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.5),
                child: _buildArtwork(track.artworkUrl),
              ),
            ),

            const SizedBox(width: 10),

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
                  const SizedBox(height: 1),

                  // Artist
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 2),

                  // 3. Bottom Status Row (Dynamic)
                  isThisTrackLoaded
                      ? _buildPlayingState(isPlaying)
                      : _buildStatsState(track),
                ],
              ),
            ),

            // 4. Trailing More Icon
            InkWell(
              key: Key('track_card_${track.id}_more_inkwell'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TrackOptionsModal(track: track),
                );
              },
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Icon(Icons.more_vert, color: Colors.grey),
              ),
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
          style: TextStyle(
            color: isPlaying ? AppTheme.primaryBrand : Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsState(Track track) {
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
          const Icon(Icons.favorite, color: AppTheme.primaryBrand, size: 14),
        ],
      ],
    );
  }

  Widget _buildArtwork(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.asset(
        url,
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.grey),
    );
  }
}
