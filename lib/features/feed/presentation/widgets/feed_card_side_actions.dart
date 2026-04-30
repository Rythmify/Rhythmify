import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/feed_item.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../track/presentation/providers/track_sync_provider.dart';
import '../../../track/presentation/providers/track_interaction_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class FeedCardSideActions extends ConsumerWidget {
  final FeedItemEntity item;

  const FeedCardSideActions({super.key, required this.item});

  Track _toTrack() {
    return Track(
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

      commentCount: item.track.commentCount,
      repostCount: 0,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseTrack = _toTrack();
    final syncedTrack = ref.watch(syncedTrackProvider(baseTrack));

    return Column(
      key: const Key('feed_card_side_actions_column'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          key: const Key('feed_card_side_actions_like'),
          icon: syncedTrack.isLiked ? Icons.favorite : Icons.favorite_border,
          label: Formatters.formatCount(syncedTrack.likeCount),
          color: syncedTrack.isLiked ? AppTheme.primaryBrand : Colors.white,
          onTap: () {
            ref
                .read(trackInteractionProvider)
                .handleToggleLike(
                  syncedTrack.id,
                  syncedTrack.isLiked,
                  currentTrack: syncedTrack,
                );
          },
        ),
        const SizedBox(height: 20),
        _ActionButton(
          key: const Key('feed_card_side_actions_comment'),
          icon: Icons.chat_outlined,
          label: Formatters.formatCount(syncedTrack.commentCount),
          onTap: () {
            context.push('/comments/${syncedTrack.id}', extra: syncedTrack);
          },
        ),
        const SizedBox(height: 20),
        _ActionButton(
          key: const Key('feed_card_side_actions_addtoplaylist'),
          icon: Icons.library_add,
          label: '',
          onTap: () {
            context.push('');
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('action_button_gesture'),
      onTap: onTap,
      child: Column(
        key: const Key('action_button_column'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
