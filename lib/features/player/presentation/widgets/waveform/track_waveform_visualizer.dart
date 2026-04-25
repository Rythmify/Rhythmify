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
    final playerState = ref.watch(playerStateProvider);
    final dragPosition = ref.watch(seekDragPositionProvider);

    // Fallback dummy data if no wave data exists yet
    final List<double> waveData =
        playerState.currentTrack?.waveformData ??
        List.generate(200, (index) => 0.1);

    final bool isPaused =
        playerState.status == PlayerStatus.paused ||
        playerState.status == PlayerStatus.initial;

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
            return CustomPaint(
              size: const Size(double.infinity, 100),
              painter: WaveformPainter(
                amplitudes: waveData,
                duration: playerState.duration,
                activePosition: dragPosition ?? playerState.position,
                actualPosition: playerState.position,
                heightMultiplier: _heightAnimation.value,
                showTimeBox: !isPaused,
              ),
            );
          },
        ),
      ),
    );
  }
}
