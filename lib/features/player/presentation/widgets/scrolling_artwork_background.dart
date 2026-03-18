import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

class ScrollingArtworkBackground extends ConsumerWidget {
  final String artworkUrl;
  const ScrollingArtworkBackground({super.key, required this.artworkUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the position, duration and status
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));
    final status = ref.watch(playerStateProvider.select((state) => state.status));

    final bool isPaused = status == PlayerStatus.paused || status == PlayerStatus.initial;

    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }
    
    // Maps progress (0.0 to 1.0) to Alignment (-1.0 to 1.0)
    final double alignmentX = -1.0 + (progress * 2.0);

    return Container(
      color: Colors.black,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: isPaused ? 20.0 : 0.0,
          sigmaY: isPaused ? 20.0 : 0.0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Image.asset(
            artworkUrl,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
            alignment: Alignment(alignmentX, 0.0),
            errorBuilder: (context, error, stackTrace) => Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[900],
              child: const Center(child: Icon(Icons.music_note, color: Colors.white24, size: 100)),
            ),
          ),
        ),
      ),
    );
  }
}
