import 'dart:ui';
import 'package:flutter/material.dart';

/// Displays the cover image for a feed card in two visual modes:
/// full-screen and compact.
///
/// In **compact mode** (default), renders a blurred version of [coverUrl]
/// as the background with a centered sharp thumbnail on top.
///
/// In **full-screen mode**, renders the image directly inside a rounded
/// bordered container with no blur effect.
///
/// Falls back to [_PlaceholderCover] when [coverUrl] is `null` or the
/// network image fails to load.
class FeedCardCover extends StatelessWidget {
  final String? coverUrl;

  /// Whether to render in full-screen mode instead of compact mode.
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
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
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 1,
          ),
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

/// A fallback cover displayed when no [coverUrl] is provided or when
/// a network image fails to load.
///
/// Renders a dark background with a centered music note icon.
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
