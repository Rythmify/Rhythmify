import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';

class WaveformGestureHandler extends ConsumerStatefulWidget {
  final Widget child;

  const WaveformGestureHandler({super.key, required this.child});

  @override
  ConsumerState<WaveformGestureHandler> createState() =>
      _WaveformGestureHandlerState();
}

class _WaveformGestureHandlerState extends ConsumerState<WaveformGestureHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    final state = ref.read(playerStateProvider);
    final durationMs = state.duration.inMilliseconds.toDouble();

    double currentMs = _controller.value;
    bool hitBoundary = false;

    // Clamp values to boundaries
    if (currentMs <= 0) {
      currentMs = 0;
      hitBoundary = true;
    } else if (currentMs >= durationMs) {
      currentMs = durationMs;
      hitBoundary = true;
    }

    // Update the UI drag state
    ref
        .read(seekDragPositionProvider.notifier)
        .setPosition(Duration(milliseconds: currentMs.round()));

    if (hitBoundary && _controller.isAnimating) {
      _controller.stop();
      _commitSeek();
    }
  }

  void _commitSeek() {
    final finalDrag = ref.read(seekDragPositionProvider);
    if (finalDrag != null) {
      // Immediately reflect the final drag position in presentation state so
      // the artwork and other UI elements continue from where the user left
      // without briefly snapping back to the pre-drag position.
      ref.read(playerStateProvider.notifier).updatePosition(finalDrag);

      // Allow the presentation state to accept incoming stream updates again.
      ref.read(playerStateProvider.notifier).setDragging(false);

      // Propagate the seek to the playback backend.
      ref.read(playerStateProvider.notifier).seek(finalDrag);

      // Keep the temporary drag position for a short time to avoid abrupt
      // flicker while the audio backend processes the seek, then clear it.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        if (!_isDragging && !_controller.isAnimating) {
          ref.read(seekDragPositionProvider.notifier).setPosition(null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerStateProvider);
    final duration = state.duration;

    if (duration.inMilliseconds == 0) return widget.child;

    const double barWidth = 3.0;
    const double spacing = 2.0;
    const double totalWaveWidth = 200 * (barWidth + spacing);

    final double msPerPixel = duration.inMilliseconds / totalWaveWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) {
        _isDragging = true;
        if (_controller.isAnimating) {
          _controller.stop();
        }

        ref.read(playerStateProvider.notifier).setDragging(true);

        final currentDrag = ref.read(seekDragPositionProvider);
        final startPos = currentDrag ?? state.position;

        ref.read(seekDragPositionProvider.notifier).setPosition(startPos);
        _controller.value = startPos.inMilliseconds.toDouble();
      },
      onHorizontalDragUpdate: (details) {
        final currentDrag = ref.read(seekDragPositionProvider);
        if (currentDrag == null) return;

        final double deltaMs = -details.primaryDelta! * msPerPixel;
        double newMs = currentDrag.inMilliseconds + deltaMs;
        newMs = newMs.clamp(0.0, duration.inMilliseconds.toDouble());

        _controller.value = newMs;
        ref
            .read(seekDragPositionProvider.notifier)
            .setPosition(Duration(milliseconds: newMs.round()));
      },
      onHorizontalDragEnd: (details) {
        _isDragging = false;

        final double velocityPx = details.velocity.pixelsPerSecond.dx;
        final double velocityMsPerSec = -velocityPx * msPerPixel;

        if (velocityPx.abs() > 150) {
          final simulation = ClampingScrollSimulation(
            position: _controller.value,
            velocity: velocityMsPerSec,
            friction: 3, // High friction for a quicker stop
            tolerance: const Tolerance(
              velocity: 200.0, // High velocity tolerance ensures a crisp stop
              distance: 1.0,
            ),
          );

          _controller.animateWith(simulation).whenComplete(() {
            if (!_isDragging) {
              _commitSeek();
            }
          });
        } else {
          _commitSeek();
        }
      },
      child: widget.child,
    );
  }
}
