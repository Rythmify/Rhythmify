import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../track/presentation/providers/track_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../track/presentation/widgets/bottom_sheets/track_options_modal.dart';

import '../../../track/presentation/providers/track_interaction_provider.dart';
import '../../../track/presentation/providers/track_sync_provider.dart';

/// A horizontal bar providing secondary track actions.
///
/// Includes like count, comments, sharing, and playlist management.
///
/// Depends on [trackDetailsProvider].

class PlayerActionBar extends ConsumerWidget {
  /// The ID of the track for which to display actions.
  final String trackId;

  /// Callback to collapse the player.
  final VoidCallback? onCollapse;

  /// Whether the actions are interactive (disabled for downloaded tracks).
  final bool isInteractive;

  const PlayerActionBar({
    super.key,
    required this.trackId,
    this.onCollapse,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackDetailsProvider(trackId));

    // Get the globally synced track state for instant UI updates
    final track = trackAsync.value != null
        ? ref.watch(syncedTrackProvider(trackAsync.value!))
        : null;

    // Changed Container to Material so the InkWell tap effects have a canvas to draw on
    return Material(
      color: AppTheme.background,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, top: 5, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ------ 1. Like Action ------
            InkWell(
              key: Key('player_action_bar_like_inkwell_$trackId'),
              onTap: isInteractive
                  ? () {
                      if (track != null) {
                        ref.read(trackInteractionProvider).handleToggleLike(
                              track.id,
                              track.isLiked,
                              currentTrack: track,
                            );
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      key: const Key('player_action_bar_favorite_icon'),
                      (track?.isLiked ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: (track?.isLiked ?? false)
                          ? AppTheme.primaryBrand
                          : (isInteractive ? Colors.white : Colors.grey),
                    ),
                    const SizedBox(width: 6),
                    !isInteractive 
                      ? const Text(
                          '0',
                          style: TextStyle(color: Colors.grey),
                        )
                      : trackAsync.when(
                          data: (_) => Text(
                            Formatters.formatCount(track?.likeCount ?? 0),
                            key: const Key('player_action_bar_like_count_text'),
                            style: AppTheme.bodyNormal.copyWith(
                              color: (track?.isLiked ?? false)
                                  ? AppTheme.primaryBrand
                                  : (isInteractive ? Colors.white : Colors.grey),
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              key: Key(
                                'player_action_bar_like_count_loading_indicator',
                              ),
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          error: (a, b) => const Text(
                            '0',
                            key: Key('player_action_bar_like_count_error_text'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // ------ 2. Comment Action ------
            InkWell(
              key: Key('player_action_bar_comment_inkwell_$trackId'),
              onTap: isInteractive
                  ? () {
                      trackAsync.whenData((track) {
                        onCollapse?.call();
                        context.pushNamed(
                          'comments',
                          pathParameters: {'trackId': track.id},
                          extra: track,
                        );
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ), // This changes the inkwell height and width
                child: Row(
                  children: [
                    Icon(
                      key: const Key('player_action_bar_comment_icon'),
                      Icons.chat_outlined,
                      color: isInteractive ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      !isInteractive ? '0' : Formatters.formatCount(track?.commentCount ?? 0),
                      key: const Key('player_action_bar_comment_count_text'),
                      style: AppTheme.bodyNormal.copyWith(
                        color: isInteractive ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ------ 3. Share Action ------
            InkWell(
              key: Key('player_action_bar_share_inkwell_$trackId'),
              onTap: isInteractive
                  ? () {
                      trackAsync.whenData((track) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => TrackOptionsModal(
                            track: track,
                            mode: TrackModalMode
                                .share, // Tell it to render the share view!
                            onCollapse: onCollapse,
                          ),
                        );
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Icon(
                  key: Key('player_action_bar_share_icon'),
                  Icons.share_outlined,
                  color: isInteractive ? Colors.white : Colors.grey,
                ),
              ),
            ),

            // ------ 4. Playlist Action ------
            InkWell(
              key: Key('player_action_bar_playlist_inkwell_$trackId'),
              onTap: isInteractive
                  ? () {
                      context.push('/queue');
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Icon(
                  key: Key('player_action_bar_playlist_icon'),
                  Icons.queue_music,
                  size: 25,
                  color: isInteractive ? Colors.white : Colors.grey,
                ),
              ),
            ),

            // ------ 5. More Action ------
            InkWell(
              key: Key('player_action_bar_more_inkwell_$trackId'),
              onTap: isInteractive
                  ? () {
                      trackAsync.whenData((track) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          useRootNavigator: true,
                          builder: (context) => TrackOptionsModal(
                            track: track,
                            onCollapse: onCollapse,
                          ),
                        );
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Icon(
                  key: Key('player_action_bar_more_icon'),
                  Icons.more_vert,
                  color: isInteractive ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
