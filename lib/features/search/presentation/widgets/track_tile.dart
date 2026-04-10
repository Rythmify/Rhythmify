import 'package:flutter/material.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/utils/formatters.dart';

/// A reusable track row showing artwork, title, artist, and formatted duration.
/// Used across the search results tabs (Tracks, All) and any other feature that lists tracks.
/// [onTap] is a placeholder — will trigger the player once routing is set up.
class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('track_tile_${track.id}'),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          track.artworkUrl,
          key: Key('track_artwork_${track.id}'),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Container(width: 50, height: 50, color: Colors.grey[800]),
        ),
      ),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          // Duration formatted via [Formatters.formatDuration] (e.g. "3:20").
          Text(
            Formatters.formatDuration(track.duration),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert),
      onTap: () {},
    );
  }
}
