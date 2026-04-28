import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import '../../../player/presentation/providers/player_provider.dart';
import 'feed_card_play_button.dart';
import '../../../../core/domain/entities/track.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/follow_button.dart';

import '../../../player/presentation/providers/queue_provider.dart';

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

  void _handlePlayTap(BuildContext context, WidgetRef ref) {
    final existingTrack = ref.read(playerStateProvider).currentTrack;
    final existingWaveform = existingTrack?.id == item.track.id
        ? existingTrack?.waveformData
        : null;

    final track = Track(
      id: item.track.id,
      userId: item.trackOwner.id,
      title: item.track.title,
      artist: item.trackOwner.displayName,
      artistPfp: item.trackOwner.avatar,
      audioUrl: item.track.streamUrl ?? item.track.audioUrl,
      coverImage: item.track.coverUrl,
      duration: Duration(seconds: item.track.duration),
      createdAt: item.createdAt,
      playCount: item.track.playCount,
      likeCount: item.track.likeCount,
      waveformData: existingWaveform,
    );

    onPlay?.call();
    ref
        .read(queueStateProvider.notifier)
        .playQueue(tracks: [track], initialIndex: 0);

    // If waveform not ready yet, wait for it then update the player state
    if (existingWaveform == null) {
      _waitForWaveformThenUpdate(ref, item.track.id);
    }
  }

  void _waitForWaveformThenUpdate(
    WidgetRef ref,
    String trackId, {
    int attempts = 0,
  }) {
    if (attempts > 40) return; // give up after 2 seconds

    Future.delayed(const Duration(milliseconds: 50), () {
      final current = ref.read(playerStateProvider).currentTrack;
      if (current?.id == trackId && current?.waveformData != null) {
        return;
      }
      _waitForWaveformThenUpdate(ref, trackId, attempts: attempts + 1);
    });
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
                    // ── Title tap: open/resume sheet, never restart audio ──
                    GestureDetector(
                      onTap: () => _handlePlayTap(context, ref),
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
                          onTap: () => context.push(
                            '/home/profile/${item.trackOwner.id}',
                          ),
                          child: CircleAvatar(
                            key: const Key('feed_card_bottom_info_avatar'),
                            radius: 14,
                            backgroundColor: Colors.white24,
                            backgroundImage: item.trackOwner.avatar != null
                                ? NetworkImage(item.trackOwner.avatar!)
                                : null,
                            child: item.trackOwner.avatar == null
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
                          onTap: () => context.push(
                            '/home/profile/${item.trackOwner.id}',
                          ),
                          child: Text(
                            key: const Key('feed_card_bottom_info_username'),
                            item.trackOwner.displayName,
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
              // ── Play circle: same behaviour as title tap ──
              GestureDetector(
                onTap: () => _handlePlayTap(context, ref),
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
