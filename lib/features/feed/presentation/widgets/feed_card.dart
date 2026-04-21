import 'package:flutter/material.dart';
import '../../domain/entities/feed_item.dart';
import 'feed_card_bottom_info.dart';
import 'feed_card_side_actions.dart';
import 'feed_card_play_button.dart';
import 'feed_card_cover.dart';
import 'feed_list.dart';

class FeedCard extends StatelessWidget {
  final FeedItemEntity item;
  final FeedTab tab;

  const FeedCard({super.key, required this.item, required this.tab});

  String get _bottomLabel {
    if (tab == FeedTab.discover) return 'Because you played...';
    if (item.type == 'repost') return '${item.user.displayName} reposted';
    return '${item.user.displayName} posted';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FeedCardCover(coverUrl: item.track.coverUrl),
        // gradient overlay
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
        Positioned(
          right: 12,
          bottom: 170,
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
              FeedCardBottomInfo(item: item),
            ],
          ),
        ),
      ],
    );
  }
}
