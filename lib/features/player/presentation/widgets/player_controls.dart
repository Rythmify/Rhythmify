import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.status == PlayerStatus.playing;
    final isLoading = playerState.status == PlayerStatus.loading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const Key('player_controls_skip_previous_iconbutton'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 36,
            ),
            onPressed: () =>
                ref.read(playerStateProvider.notifier).skipToPrevious(),
          ),

          const SizedBox(width: 60),

          GestureDetector(
            key: const Key('player_controls_toggle_play_pause_gesturedetector'),
            onTap: () =>
                ref.read(playerStateProvider.notifier).togglePlayPause(),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBrand,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        key: Key('player_controls_loading_indicator'),
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      key: const Key('player_controls_play_pause_icon'),
                      color: Colors.white,
                      size: 36,
                    ),
            ),
          ),

          const SizedBox(width: 60),

          IconButton(
            key: const Key('player_controls_skip_next_iconbutton'),
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
            onPressed: () =>
                ref.read(playerStateProvider.notifier).skipToNext(),
          ),
        ],
      ),
    );
  }
}
