import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/providers/player_provider.dart';

class FeedCardPlayCircle extends ConsumerWidget {
  final bool showProgress;
  final double size;

  const FeedCardPlayCircle({
    super.key,
    required this.showProgress,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(playerStateProvider.select((s) => s.position));
    final duration = ref.watch(playerStateProvider.select((s) => s.duration));

    double progress = 0.0;
    if (showProgress && duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return SizedBox(
      key: const Key('feed_card_play_circle_sizedbox'),
      width: size,
      height: size,
      child: Stack(
        key: const Key('feed_card_play_circle_stack'),
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            key: const Key('feed_card_play_circle_progress'),
            value: showProgress ? progress : 0,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            backgroundColor: Colors.white24,
          ),
          Center(
            key: const Key('feed_card_play_circle_center'),
            child: Icon(
              key: const Key('feed_card_play_circle_icon'),
              Icons.play_arrow,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
