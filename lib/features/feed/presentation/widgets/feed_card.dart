import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import 'feed_card_bottom_info.dart';
import 'feed_card_side_actions.dart';
import 'feed_card_cover.dart';
import 'feed_list.dart';

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
      key: const Key('feed_card_stack'),
      fit: StackFit.expand,
      children: [
        FeedCardCover(
          key: const Key('feed_card_cover'),
          coverUrl: item.track.coverUrl,
          fullScreen: fullScreen,
        ),
        const DecoratedBox(
          key: Key('feed_card_gradient'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xD9000000)],
              stops: [0.45, 1.0],
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            key: const Key('feed_card_animated_opacity'),
            duration: const Duration(milliseconds: 300),
            opacity: (previewMode || isThisTrackNowPlaying) ? 0.0 : 0.45,
            child: const ColoredBox(
              key: Key('feed_card_dark_overlay'),
              color: Colors.black,
              child: SizedBox.expand(),
            ),
          ),
        ),
        if (showTapToPreview)
          const IgnorePointer(
            child: Center(
              key: Key('feed_card_tap_to_preview_center'),
              child: Column(
                key: Key('feed_card_tap_to_preview_column'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key: Key('feed_card_tap_to_preview_text'),
                    'Tap to preview',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    key: Key('feed_card_tap_to_preview_icon'),
                    Icons.volume_off,
                    color: Colors.white54,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        if (isThisTrackNowPlaying)
          const IgnorePointer(
            child: Center(
              key: Key('feed_card_now_playing_center'),
              child: Column(
                key: Key('feed_card_now_playing_column'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key: Key('feed_card_now_playing_text'),
                    'Now Playing',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    key: Key('feed_card_now_playing_icon'),
                    Icons.equalizer,
                    color: Colors.white54,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        Positioned(
          key: const Key('feed_card_side_actions_positioned'),
          right: 12,
          bottom: 200,
          child: FeedCardSideActions(
            key: const Key('feed_card_side_actions'),
            item: item,
          ),
        ),
        Positioned(
          key: const Key('feed_card_bottom_positioned'),
          left: 12,
          right: 12,
          bottom: 62,
          child: Column(
            key: const Key('feed_card_bottom_column'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                key: const Key('feed_card_bottom_label_padding'),
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  key: const Key('feed_card_bottom_label_text'),
                  _bottomLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              FeedCardBottomInfo(
                key: const Key('feed_card_bottom_info'),
                item: item,
                onPlay: onPlay,
                showProgress: previewMode,
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
