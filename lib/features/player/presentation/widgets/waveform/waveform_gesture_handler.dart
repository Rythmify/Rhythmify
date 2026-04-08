import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';

class WaveformGestureHandler extends ConsumerWidget {
  final Widget child;

  const WaveformGestureHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStateProvider);
    final duration = state.duration;

    if (duration.inMilliseconds == 0) return child;

    // The total physical width the wave takes up
    const double barWidth = 3.0;
    const double spacing = 2.0;
    const double totalWaveWidth = 200 * (barWidth + spacing);

    // Milliseconds per pixel of swipe
    final double msPerPixel = duration.inMilliseconds / totalWaveWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) {
        ref.read(playerStateProvider.notifier).setDragging(true);
        // Initialize drag with current real position
        ref.read(seekDragPositionProvider.notifier).setPosition(state.position);
      },
      onHorizontalDragUpdate: (details) {
        final currentDrag = ref.read(seekDragPositionProvider);
        if (currentDrag == null) return;

        // Moving finger left moves wave left (progresses time) -> reverse the delta
        final double deltaMs = -details.primaryDelta! * msPerPixel;

        int newMs = currentDrag.inMilliseconds + deltaMs.round();
        newMs = newMs.clamp(0, duration.inMilliseconds);

        ref
            .read(seekDragPositionProvider.notifier)
            .setPosition(Duration(milliseconds: newMs));
      },
      onHorizontalDragEnd: (details) {
        final finalDrag = ref.read(seekDragPositionProvider);
        if (finalDrag != null) {
          ref.read(playerStateProvider.notifier).seek(finalDrag);
          // Wait slightly for audio handler to catch up before releasing UI state
          Future.delayed(const Duration(milliseconds: 200), () {
            ref.read(seekDragPositionProvider.notifier).setPosition(null);
            ref.read(playerStateProvider.notifier).setDragging(false);
          });
        }
      },
      child: child,
    );
  }
}
