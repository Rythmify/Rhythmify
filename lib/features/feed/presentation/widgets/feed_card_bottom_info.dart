import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import '../../../player/presentation/providers/player_provider.dart';
import 'feed_card_play_button.dart';
import '../../../../core/domain/entities/track.dart';
import '../providers/feed_providers.dart';

class FeedCardBottomInfo extends ConsumerWidget {
  // Changed to ConsumerWidget
  final FeedItemEntity item;
  final VoidCallback? onPlay;
  final bool showProgress;

  const FeedCardBottomInfo({
    super.key,
    required this.item,
    this.onPlay,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    return GestureDetector(
      onTap: () {
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

          // Wait for sheet to mount before expanding
          Future.delayed(const Duration(milliseconds: 300), () {
            playerSheetNotifier.value?.call();
          });
          onPlay?.call();
          return;
        }
        onPlay?.call();

        playerSheetNotifier.value?.call();
      },
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 5,
              bottom: 20,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.12),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        item.track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            backgroundImage: item.user.avatar != null
                                ? NetworkImage(item.user.avatar!)
                                : null,
                            child: item.user.avatar == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.track.uploaderUsername,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FollowButton(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FeedCardPlayCircle(showProgress: showProgress, size: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white60),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text('Follow', style: TextStyle(fontSize: 12)),
    );
  }
}
