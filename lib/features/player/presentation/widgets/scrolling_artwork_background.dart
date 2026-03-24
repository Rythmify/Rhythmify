import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

/// A dynamic background widget that scrolls the track artwork based on playback progress.
///
/// It also applies a blur effect when the player is paused to emphasize controls.
///
/// Depends on [playerStateProvider].
class ScrollingArtworkBackground extends ConsumerWidget {
  /// The local or remote URL of the artwork to display.
  final String artworkUrl;

  const ScrollingArtworkBackground({super.key, required this.artworkUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches progress and status for real-time visual updates.
    final position = ref.watch(
      playerStateProvider.select((state) => state.position),
    );
    final duration = ref.watch(
      playerStateProvider.select((state) => state.duration),
    );
    final status = ref.watch(
      playerStateProvider.select((state) => state.status),
    );

    final bool isPaused =
        status == PlayerStatus.paused || status == PlayerStatus.initial;

    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    // Maps progress (0.0 to 1.0) to Alignment (-1.0 to 1.0) for the scrolling effect.
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
            key: const Key('player_scrolling_artwork_image'),
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
            alignment: Alignment(alignmentX, 0.0),
            errorBuilder: (context, error, stackTrace) => Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[900],
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  key: Key('player_scrolling_artwork_error_icon'),
                  color: Colors.white24,
                  size: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
