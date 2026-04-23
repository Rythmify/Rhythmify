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
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: coverUrl != null
                ? Image.network(
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
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coverUrl != null)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Image.network(coverUrl!, fit: BoxFit.cover),
                )
              else
                const _PlaceholderCover(),
              Container(color: Colors.black.withOpacity(0.4)),
              Align(
                alignment: const Alignment(0, -0.5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 250,
                    height: 300,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 60),
                    child: coverUrl != null
                        ? Image.network(
                            coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
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
      color: const Color(0xFF1A1A1A),
      child: const Icon(Icons.music_note, color: Colors.white24, size: 80),
    );
  }
}
