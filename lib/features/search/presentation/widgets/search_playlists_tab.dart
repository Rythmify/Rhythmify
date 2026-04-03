import 'package:flutter/material.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // scaffold — wire up when teammate's Playlist model is ready
    return Center(
      child: Text(
        'No playlists found',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
