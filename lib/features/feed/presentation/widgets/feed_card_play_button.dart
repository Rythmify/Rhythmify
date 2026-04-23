// feed_card_play_circle.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

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
    final status = ref.watch(playerStateProvider.select((s) => s.status));
    final position = ref.watch(playerStateProvider.select((s) => s.position));
    final duration = ref.watch(playerStateProvider.select((s) => s.duration));

    final isPlaying = status == PlayerStatus.playing;

    double progress = 0.0;
    if (showProgress && duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: showProgress ? progress : 0,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            backgroundColor: Colors.white24,
          ),
          Center(
            child: Icon(
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
