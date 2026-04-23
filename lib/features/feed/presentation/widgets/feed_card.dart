import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import 'feed_card_bottom_info.dart';
import 'feed_card_side_actions.dart';
import 'feed_card_cover.dart';
import 'feed_list.dart';
import 'feed_card_play_button.dart';

class FeedCard extends ConsumerWidget {
  final FeedItemEntity item;
  final FeedTab tab;
  final bool previewMode;
  final String? nowPlayingTrackId;
  final VoidCallback? onPlay;
  final bool fullScreen;

  const FeedCard({
    super.key,
    required this.item,
    required this.tab,
    required this.previewMode,
    this.nowPlayingTrackId,
    this.onPlay,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThisTrackNowPlaying = nowPlayingTrackId == item.track.id;
    final showTapToPreview = !previewMode && !isThisTrackNowPlaying;

    return Stack(
      fit: StackFit.expand,
      children: [
        FeedCardCover(coverUrl: item.track.coverUrl, fullScreen: fullScreen),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xD9000000)],
              stops: [0.45, 1.0],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: (previewMode || isThisTrackNowPlaying) ? 0.0 : 0.45,
          child: const ColoredBox(
            color: Colors.black,
            child: SizedBox.expand(),
          ),
        ),
        if (showTapToPreview)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tap to preview',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(Icons.volume_off, color: Colors.white54, size: 36),
                SizedBox(height: 10),
              ],
            ),
          ),
        if (isThisTrackNowPlaying)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(Icons.equalizer, color: Colors.white54, size: 36),
                SizedBox(height: 10),
              ],
            ),
          ),
        Positioned(
          right: 12,
          bottom: 200,
          child: FeedCardSideActions(item: item),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  _bottomLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              FeedCardBottomInfo(
                item: item,
                onPlay: onPlay,
                showProgress: previewMode, // ADD
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _bottomLabel {
    if (item.discoverLabel != null) return item.discoverLabel!;
    if (tab == FeedTab.discover) return 'Discovered for you';
    if (item.type == 'repost') return '${item.user.displayName} reposted';
    return '${item.user.displayName} posted';
  }
}
