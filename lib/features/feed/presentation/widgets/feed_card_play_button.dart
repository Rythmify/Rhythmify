import 'package:flutter/material.dart';

class FeedCardPlayButton extends StatefulWidget {
  final String audioUrl;

  const FeedCardPlayButton({super.key, required this.audioUrl});

  @override
  State<FeedCardPlayButton> createState() => _FeedCardPlayButtonState();
}

class _FeedCardPlayButtonState extends State<FeedCardPlayButton> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: wire up audio player
        setState(() => _playing = !_playing);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _playing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
