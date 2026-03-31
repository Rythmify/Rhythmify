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
  final String artworkUrl;

  const ScrollingArtworkBackground({super.key, required this.artworkUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(
      playerStateProvider.select((state) => state.position),
    );
    final duration = ref.watch(
      playerStateProvider.select((state) => state.duration),
    );
    final status = ref.watch(
      playerStateProvider.select((state) => state.status),
    );
    final dragPosition = ref.watch(seekDragPositionProvider);
    final activePosition = dragPosition ?? position;

    final bool isDragging = dragPosition != null;
    final bool isPaused =
        status == PlayerStatus.paused || status == PlayerStatus.initial;

    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = activePosition.inMilliseconds / duration.inMilliseconds;
    }

    // Alignment logic (for scrolling)
    final double alignmentX = -1.0 + (progress * 2.0);

    // Unifying the animation config
    const animationDuration = Duration(milliseconds: 200);
    const animationCurve = Curves.easeOutCubic;

    // Scale Value based on state
    final double imageScale = (isPaused || isDragging) ? 1.05 : 1.0;
    final bool isNetworkImage = artworkUrl.startsWith('http');

    Widget errorPlaceholder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white24, size: 100),
        ),
      );
    }

    // Direct alignment for smooth finger tracking
    Widget buildArtwork(String keySuffix) {
      return isNetworkImage
          ? Image.network(
              artworkUrl,
              key: Key('player_artwork_network_$keySuffix'),
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
              alignment: Alignment(alignmentX, 0.0),
              errorBuilder: errorPlaceholder,
            )
          : Image.asset(
              artworkUrl,
              key: Key('player_artwork_asset_$keySuffix'),
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
              alignment: Alignment(alignmentX, 0.0),
              errorBuilder: errorPlaceholder,
            );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The Base Image Layer
          AnimatedScale(
            scale: imageScale,
            duration: animationDuration,
            curve: animationCurve,
            alignment: Alignment.center,
            child: buildArtwork('base'),
          ),

          // --------- Optimized Static Blur Layer ----------
          // We apply the blur strictly to a duplicated image,
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: (isPaused || isDragging) ? 1.0 : 0.0,
              duration: animationDuration,
              curve: animationCurve,
              child: AnimatedScale(
                scale: imageScale,
                duration: animationDuration,
                curve: animationCurve,
                alignment: Alignment.center,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 25.0,
                    sigmaY: 25.0,
                    tileMode: TileMode.mirror,
                  ),
                  child: buildArtwork('blur'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
