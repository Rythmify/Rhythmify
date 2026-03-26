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
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));
    final status = ref.watch(playerStateProvider.select((state) => state.status));
    final dragPosition = ref.watch(seekDragPositionProvider);
    
    final activePosition = dragPosition ?? position;
    final bool isDragging = dragPosition != null;
    final bool isPaused = status == PlayerStatus.paused || status == PlayerStatus.initial;
    
    final bool shouldApplyEffects = isPaused || isDragging;

    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = activePosition.inMilliseconds / duration.inMilliseconds;
    }

    final double alignmentX = -1.0 + (progress * 2.0);
    final double imageScale = shouldApplyEffects ? 1.05 : 1.0;
    
    // Target blur value
    final double targetBlurSigma = shouldApplyEffects ? 25.0 : 0.0;
    final bool isNetworkImage = artworkUrl.startsWith('http');

    Widget errorPlaceholder(BuildContext context, Object error, StackTrace? stackTrace) {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white24, size: 100),
        ),
      );
    }

    // Helper to keep the builder clean
    Widget buildArtworkImage(double alignX) {
      return isNetworkImage
        ? Image.network(
            artworkUrl,
            key: const Key('player_artwork_network'),
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
            alignment: Alignment(alignX, 0.0),
            errorBuilder: errorPlaceholder,
          )
        : Image.asset(
            artworkUrl,
            key: const Key('player_artwork_asset'),
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
            alignment: Alignment(alignX, 0.0),
            errorBuilder: errorPlaceholder,
          );
    }

    return Container(
      color: Colors.black,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetBlurSigma),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, sigma, child) {
          return ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: sigma > 0 ? sigma : 0.001, 
              sigmaY: sigma > 0 ? sigma : 0.001,
            ),
            child: child,
          );
        },

        child: AnimatedScale(
          scale: imageScale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          child: buildArtworkImage(alignmentX),
        ),
      ),
    );
  }
}