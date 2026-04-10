import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';

class TrendingTracks extends ConsumerWidget {
  const TrendingTracks({super.key, required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<List<Track>> chunks = [];
    for (var i = 0; i < tracks.length; i += 3) {
      chunks.add(
        tracks.sublist(i, (i + 3 > tracks.length) ? tracks.length : i + 3),
      );
    }

    return SizedBox(
      height: 216,
      child: ListView.separated(
        key: const Key('trending_tracks_list'),
        scrollDirection: Axis.horizontal,
        itemCount: chunks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, chunkIndex) {
          final chunk = chunks[chunkIndex];
          return SizedBox(
            width: 350,
            child: Column(
              children: chunk.map((track) {
                return SizedBox(
                  height: 72,
                  child: ListTile(
                    key: Key('trending_track_${track.id}'),
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        track.artworkUrl.isNotEmpty
                            ? track.artworkUrl
                            : 'assets/images/placeholder.png',
                        key: Key('trending_track_artwork_${track.id}'),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    title: Text(
                      track.title,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artist,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.more_horiz, color: Colors.white),
                    onTap: () {},
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
