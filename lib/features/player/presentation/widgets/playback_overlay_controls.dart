import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

/// An overlay widget that displays primary playback controls (prev, play/pause, next).
///
/// This overlay is typically shown when the player is in a paused state to
/// provide clear control options over the background artwork.
///
/// Depends on [playerStateProvider].
class PlaybackOverlayControls extends ConsumerWidget {
  const PlaybackOverlayControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when the playing status changes (play vs pause)
    final status = ref.watch(
      playerStateProvider.select((state) => state.status),
    );
    final bool isPaused = status != PlayerStatus.playing;

    return IgnorePointer(
      ignoring: !isPaused,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: isPaused
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.transparent,
        child: isPaused
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleControlButton(
                      key: const Key(
                        'player_overlay_skip_previous_gesturedetector',
                      ),
                      icon: Icons.skip_previous,
                      onTap: () => ref
                          .read(playerStateProvider.notifier)
                          .skipToPrevious(),
                    ),
                    const SizedBox(width: 32),
                    _buildCircleControlButton(
                      key: const Key(
                        'player_overlay_play_pause_gesturedetector',
                      ),
                      icon: Icons.play_arrow,
                      size: 55,
                      iconSize: 35,
                      color: const Color.fromARGB(255, 18, 18, 18),
                      onTap: () => ref
                          .read(playerStateProvider.notifier)
                          .togglePlayPause(),
                    ),
                    const SizedBox(width: 32),
                    _buildCircleControlButton(
                      key: const Key(
                        'player_overlay_skip_next_gesturedetector',
                      ),
                      icon: Icons.skip_next,
                      onTap: () =>
                          ref.read(playerStateProvider.notifier).skipToNext(),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Helper to build consistent circular control buttons.
  Widget _buildCircleControlButton({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
    double size = 42,
    double iconSize = 25,
    Color? color,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? const Color.fromARGB(255, 18, 18, 18),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
