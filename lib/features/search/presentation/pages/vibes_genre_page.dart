import 'package:flutter/material.dart';

class GenrePage extends StatelessWidget {
  final String genre;

  const GenrePage({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(genre)),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "$genre Music",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          const Text("Trending Tracks"),
          const SizedBox(height: 10),

          ...List.generate(
            6,
            (i) => ListTile(
              leading: const Icon(Icons.music_note),
              title: Text("$genre Track ${i + 1}"),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Playlists"),
          const SizedBox(height: 10),

          ...List.generate(
            3,
            (i) => ListTile(
              leading: const Icon(Icons.playlist_play),
              title: Text("$genre Playlist ${i + 1}"),
            ),
          ),
        ],
      ),
    );
  }
}
