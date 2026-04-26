import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/ui_utils.dart';
import 'bottom_sheets/track_options_modal.dart';
import '../../../../core/domain/entities/track.dart';
import '../providers/track_interaction_provider.dart';
import '../providers/track_sync_provider.dart';

/// A horizontal bar containing interactive engagement metrics and playback controls.
///
/// Displays formatted counts for likes, comments, and reposts. It also includes
/// a primary play/pause button that interacts directly with the [playerStateProvider]
/// to control playback or load the track into the active queue.
///
/// Expects a [track] entity to display accurate engagement numbers and handle playback.
class TrackActionBar extends ConsumerWidget {
  final Track track;

  const TrackActionBar({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the globally synced track state for instant UI updates
    final syncedTrack = ref.watch(syncedTrackProvider(track));

    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.status == PlayerStatus.playing;
    final isThisTrack = playerState.currentTrack?.id == syncedTrack.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildActionButton(
            syncedTrack.isLiked ? Icons.favorite : Icons.favorite_border,
            Formatters.formatCount(syncedTrack.likeCount),
            onTap: () {
              ref
                  .read(trackInteractionProvider)
                  .handleToggleLike(
                    syncedTrack.id,
                    syncedTrack.isLiked,
                    currentTrack: syncedTrack,
                  );
            },
            iconColor: syncedTrack.isLiked
                ? AppTheme.primaryBrand
                : AppTheme.fadedWhite,
            textColor: syncedTrack.isLiked
                ? AppTheme.primaryBrand
                : AppTheme.fadedWhite,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            Icons.repeat,
            Formatters.formatCount(syncedTrack.repostCount),
            onTap: () async {
              try {
                await ref
                    .read(trackInteractionProvider)
                    .handleToggleRepost(
                      syncedTrack.id,
                      syncedTrack.isReposted,
                      currentTrack: syncedTrack,
                    );
              } catch (e) {
                if (context.mounted) {
                  UIUtils.showErrorSnackBar(
                    context,
                    ErrorHandler.getFriendlyMessage(e),
                  );
                }
              }
            },
            iconColor: syncedTrack.isReposted
                ? AppTheme.primaryBrand
                : AppTheme.fadedWhite,
            textColor: syncedTrack.isReposted
                ? AppTheme.primaryBrand
                : AppTheme.fadedWhite,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            Icons.chat_outlined,
            Formatters.formatCount(syncedTrack.commentCount),
            onTap: () {
              context.push(
                '/home/comments/${syncedTrack.id}',
                extra: syncedTrack,
              );
            },
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TrackOptionsModal(track: syncedTrack),
              );
            },
            borderRadius: BorderRadius.circular(8),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: Icon(Icons.more_vert, color: AppTheme.fadedWhite),
            ),
          ),
          const Spacer(),
          GestureDetector(
            key: const Key('behind_the_track_play_pause_gesture_detector'),
            onTap: () {
              if (isThisTrack) {
                ref.read(playerStateProvider.notifier).togglePlayPause();
              } else {
                ref.read(playerStateProvider.notifier).loadAndPlayQueue([
                  syncedTrack,
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

  Widget _buildActionButton(
    IconData icon,
    String value, {
    VoidCallback? onTap,
    Color iconColor = AppTheme.fadedWhite,
    Color textColor = AppTheme.fadedWhite,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTheme.labelLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
