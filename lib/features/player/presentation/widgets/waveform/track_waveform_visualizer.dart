import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';
import '../../../domain/entities/player_state.dart';
import 'waveform_painter.dart';
import 'waveform_gesture_handler.dart';

class TrackWaveformVisualizer extends ConsumerStatefulWidget {
  const TrackWaveformVisualizer({super.key});

  @override
  ConsumerState<TrackWaveformVisualizer> createState() =>
      _TrackWaveformVisualizerState();
}

class _TrackWaveformVisualizerState
    extends ConsumerState<TrackWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch status and metadata, but NOT position for the widget build itself.
    final status = ref.watch(playerStateProvider.select((s) => s.status));
    final duration = ref.watch(playerStateProvider.select((s) => s.duration));
    final waveData =
        ref.watch(
          playerStateProvider.select((s) => s.currentTrack?.waveformData),
        ) ??
        List.generate(200, (index) => 0.1);

    final dragPosition = ref.watch(seekDragPositionProvider);

    final bool isPaused =
        status == PlayerStatus.paused || status == PlayerStatus.initial;

    if (isPaused) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    return WaveformGestureHandler(
      child: SizedBox(
        width: double.infinity,
        height: 120, // Maximum height bounds for the top/bot amplitudes
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Inner watch for position inside AnimatedBuilder or use playerStateProvider.position
            // BUT we want position updates to only repaint, not rebuild the whole subtree.
            // Using a Consumer here to isolate position-driven repaints.
            return Consumer(
              builder: (context, ref, _) {
                final position = ref.watch(
                  playerStateProvider.select((s) => s.position),
                );
                return CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: WaveformPainter(
                    amplitudes: waveData,
                    duration: duration,
                    activePosition: dragPosition ?? position,
                    actualPosition: position,
                    heightMultiplier: _heightAnimation.value,
                    showTimeBox: !isPaused,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
