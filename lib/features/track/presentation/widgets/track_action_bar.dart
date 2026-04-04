import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// A horizontal bar containing interactive engagement metrics and playback controls.
///
/// Displays formatted counts for likes, comments, and reposts. It also includes
/// a primary play/pause button that interacts directly with the [playerStateProvider]
/// to control playback or load the track into the active queue.
///
/// Expects a [track] entity to display accurate engagement numbers and handle playback.

class TrackActionBar extends ConsumerWidget {
  final dynamic track;

  const TrackActionBar({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.status == PlayerStatus.playing;
    final isThisTrack = playerState.currentTrack?.id == track.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildActionButton(
            Icons.favorite_border,
            Formatters.formatCount(track.likeCount),
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            Icons.repeat,
            Formatters.formatCount(track.repostCount),
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            Icons.chat_outlined,
            Formatters.formatCount(track.commentCount),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.more_vert, color: AppTheme.fadedWhite),
          const Spacer(),
          GestureDetector(
            key: const Key('behind_the_track_play_pause_gesture_detector'),
            onTap: () {
              if (isThisTrack) {
                ref.read(playerStateProvider.notifier).togglePlayPause();
              } else {
                ref.read(playerStateProvider.notifier).loadAndPlayQueue([
                  track,
                ]);
              }
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying && isThisTrack ? Icons.pause : Icons.play_arrow,
                color: AppTheme.background,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.fadedWhite, size: 24),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.fadedWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
