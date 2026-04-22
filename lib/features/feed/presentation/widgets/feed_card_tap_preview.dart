import 'package:flutter/material.dart';
import '../../domain/entities/feed_item.dart';
import '../../../../core/domain/entities/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/providers/player_provider.dart';

class TapToPreview extends ConsumerStatefulWidget {
  final FeedItemEntity item;

  const TapToPreview({required this.item});

  @override
  ConsumerState<TapToPreview> createState() => _TapToPreviewState();
}

class _TapToPreviewState extends ConsumerState<TapToPreview> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        setState(() => _visible = false);

        final track = Track(
          id: widget.item.track.id,
          userId: widget.item.user.id,
          title: widget.item.track.title,
          artist: widget.item.user.displayName,
          artistPfp: widget.item.user.avatar,
          audioUrl: widget.item.track.audioUrl,
          coverImage: widget.item.track.coverUrl,
          duration: Duration(seconds: widget.item.track.duration),
          createdAt: widget.item.createdAt,
          playCount: widget.item.track.playCount,
          likeCount: widget.item.track.likeCount,
        );

        ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'Tap to preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
