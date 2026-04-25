import 'dart:ui';
import 'package:flutter/material.dart';

class FeedCardCover extends StatelessWidget {
  final String? coverUrl;
  final bool fullScreen;

  const FeedCardCover({super.key, this.coverUrl, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return Padding(
        key: const Key('feed_card_cover_fullscreen_padding'),
        padding: const EdgeInsets.all(10),
        child: Container(
          key: const Key('feed_card_cover_fullscreen_container'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          child: ClipRRect(
            key: const Key('feed_card_cover_fullscreen_clip'),
            borderRadius: BorderRadius.circular(20),
            child: coverUrl != null
                ? Image.network(
                    key: const Key('feed_card_cover_fullscreen_image'),
                    coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _PlaceholderCover(),
                  )
                : const _PlaceholderCover(),
          ),
        ),
      );
    }

    return Padding(
      key: const Key('feed_card_cover_padding'),
      padding: const EdgeInsets.all(12),
      child: Container(
        key: const Key('feed_card_cover_container'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1),
        ),
        child: ClipRRect(
          key: const Key('feed_card_cover_clip'),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            key: const Key('feed_card_cover_stack'),
            fit: StackFit.expand,
            children: [
              if (coverUrl != null)
                ImageFiltered(
                  key: const Key('feed_card_cover_blur'),
                  imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Image.network(coverUrl!, fit: BoxFit.cover),
                )
              else
                const _PlaceholderCover(),
              Container(
                key: const Key('feed_card_cover_overlay'),
                color: Colors.black.withValues(alpha: 0.4),
              ),
              Align(
                key: const Key('feed_card_cover_align'),
                alignment: const Alignment(0, -0.5),
                child: ClipRRect(
                  key: const Key('feed_card_cover_inner_clip'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    key: const Key('feed_card_cover_inner_container'),
                    width: 250,
                    height: 300,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 60),
                    child: coverUrl != null
                        ? Image.network(
                            key: const Key('feed_card_cover_inner_image'),
                            coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _PlaceholderCover(),
                          )
                        : const _PlaceholderCover(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('feed_card_cover_placeholder'),
      color: const Color(0xFF1A1A1A),
      child: const Icon(
        key: Key('feed_card_cover_placeholder_icon'),
        Icons.music_note,
        color: Colors.white24,
        size: 80,
      ),
    );
  }
}
