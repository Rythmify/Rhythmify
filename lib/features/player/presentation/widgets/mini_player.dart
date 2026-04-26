import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../providers/queue_provider.dart';
import '../../../track/presentation/providers/track_interaction_provider.dart';
import '../../../track/presentation/providers/track_sync_provider.dart';
import '../../../../core/presentation/widgets/follow_button.dart';
import 'mini_player_progress_button.dart';

/// A persistent mini-player widget that appears when a track is active.
///
/// This widget provides basic playback information and quick actions (like, follow)
/// and allows the user to expand the full player.
///
/// Depends on [playerStateProvider] and [trackInteractionProvider].

class MiniPlayer extends ConsumerWidget {
  /// Callback triggered when the mini-player is tapped to expand.
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when the song changes -> not when the timer ticks
    final baseTrack = ref.watch(
      playerStateProvider.select((state) => state.currentTrack),
    );

    if (baseTrack == null) return const SizedBox.shrink();

    // Get the globally synced track state for instant UI updates
    final track = ref.watch(syncedTrackProvider(baseTrack));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 11.0),
      child: GestureDetector(
        key: const Key('player_mini_player_gesture_detector'),
        onTap: onTap,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -300) {
            // Swipe Left -> Next
            ref.read(queueStateProvider.notifier).nextTrack();
          } else if (velocity > 300) {
            // Swipe Right -> Prev
            ref.read(queueStateProvider.notifier).previousTrack();
          }
        },

        // ------- Mini Player Styling ------
        child: Container(
          height: 58,
          padding: const EdgeInsets.only(left: 8, right: 16),
          decoration: BoxDecoration(
            color: AppTheme.miniPlayer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.7,
            ),
          ),

          child: Row(
            children: [
              const SizedBox(width: 5),
              const MiniPlayerProgressButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      key: const Key('player_mini_player_title_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.miniPlayerFont1,
                    ),
                    Text(
                      track.artist,
                      key: const Key('player_mini_player_artist_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.miniPlayerFont2,
                    ),
                  ],
                ),
              ),

              FollowButton(
                targetUserId: track.userId,
                builder: (context, isFollowing, isInFlight, toggle) {
                  return IconButton(
                    key: const Key('player_mini_player_follow_icon_button'),
                    icon: Icon(
                      isFollowing
                          ? Icons.person_add_alt_1
                          : Icons.person_add_alt,
                    ),
                    color: isFollowing ? AppTheme.primaryBrand : Colors.white,
                    onPressed: toggle,
                  );
                },
              ),

              IconButton(
                key: const Key('player_mini_player_like_icon_button'),
                icon: Icon(
                  track.isLiked ? Icons.favorite : Icons.favorite_border,
                ),
                color: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                onPressed: () {
                  ref
                      .read(trackInteractionProvider)
                      .handleToggleLike(
                        track.id,
                        track.isLiked,
                        currentTrack: track,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
