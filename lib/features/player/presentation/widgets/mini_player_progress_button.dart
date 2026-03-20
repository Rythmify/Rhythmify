import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

class MiniPlayerProgressButton extends ConsumerWidget {
  const MiniPlayerProgressButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the rapidly changing timer
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));
    final status = ref.watch(playerStateProvider.select((state) => state.status));

    final isPlaying = status == PlayerStatus.playing;
    
    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return GestureDetector(
      key: const Key('player_mini_progress_button_toggle_play_pause_gesturedetector'),
      onTap: () => ref.read(playerStateProvider.notifier).togglePlayPause(),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              key: const Key('player_mini_progress_button_indicator'),
              value: progress,
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBrand), 
              backgroundColor: Colors.black87, 
            ),
            // The white play/pause button
            Padding(
              padding: const EdgeInsets.all(1.5), 
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  key: const Key('player_mini_progress_button_icon'),
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}