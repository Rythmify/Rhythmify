import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import '../../../player/presentation/providers/player_provider.dart';
import 'feed_card_play_button.dart';
import '../../../../core/domain/entities/track.dart';
import '../providers/feed_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/follow_button.dart';

class FeedCardBottomInfo extends ConsumerWidget {
  final FeedItemEntity item;
  final VoidCallback? onPlay;
  final bool showProgress;

  const FeedCardBottomInfo({
    super.key,
    required this.item,
    this.onPlay,
    this.showProgress = false,
  });

  void _handlePlayTap(WidgetRef ref) {
    final playerState = ref.read(playerStateProvider);
    final isThisTrackLoaded = playerState.currentTrack?.id == item.track.id;

    if (isThisTrackLoaded) {
      ref.read(playerStateProvider.notifier).togglePlayPause();
    } else {
      final track = Track(
        id: item.track.id,
        userId: item.user.id,
        title: item.track.title,
        artist: item.user.displayName,
        artistPfp: item.user.avatar,
        audioUrl: item.track.audioUrl,
        coverImage: item.track.coverUrl,
        duration: Duration(seconds: item.track.duration),
        createdAt: item.createdAt,
        playCount: item.track.playCount,
        likeCount: item.track.likeCount,
      );
      ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
      Future.delayed(const Duration(milliseconds: 300), () {
        playerSheetNotifier.value?.call();
      });
      onPlay?.call();
      return;
    }
    onPlay?.call();
    playerSheetNotifier.value?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      key: const Key('feed_card_bottom_info_clip'),
      child: BackdropFilter(
        key: const Key('feed_card_bottom_info_backdrop'),
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          key: const Key('feed_card_bottom_info_container'),
          padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            key: const Key('feed_card_bottom_info_row'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  key: const Key('feed_card_bottom_info_column'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _handlePlayTap(ref),
                      child: Text(
                        key: const Key('feed_card_bottom_info_title'),
                        item.track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      key: const Key('feed_card_bottom_info_artist_row'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              context.push('/home/profile/${item.user.id}'),
                          child: CircleAvatar(
                            key: const Key('feed_card_bottom_info_avatar'),
                            radius: 14,
                            backgroundColor: Colors.white24,
                            backgroundImage: item.user.avatar != null
                                ? NetworkImage(item.user.avatar!)
                                : null,
                            child: item.user.avatar == null
                                ? const Icon(
                                    key: Key(
                                      'feed_card_bottom_info_avatar_icon',
                                    ),
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 14,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              context.push('/home/profile/${item.user.id}'),
                          child: Text(
                            key: const Key('feed_card_bottom_info_username'),
                            item.user.displayName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FollowButton(targetUserId: item.user.id, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _handlePlayTap(ref),
                child: FeedCardPlayCircle(
                  key: const Key('feed_card_bottom_info_play_circle'),
                  showProgress: showProgress,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed private _FollowButton class as it's replaced by unified FollowButton
