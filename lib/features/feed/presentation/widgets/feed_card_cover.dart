import 'package:flutter/material.dart';

class FeedCardCover extends StatelessWidget {
  final String? coverUrl;

  const FeedCardCover({super.key, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(10, 30, 10, 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _PlaceholderCover(),
              )
            : const _PlaceholderCover(),
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
