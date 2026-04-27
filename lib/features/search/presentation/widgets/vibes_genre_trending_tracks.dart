import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';
import '../../../track/presentation/widgets/bottom_sheets/track_options_modal.dart';

/// A horizontally scrollable list of trending tracks shown in the All tab.
/// Tracks are grouped into chunks of 3, each chunk rendered as a vertical column
/// in a 350px-wide page — creating a paginated horizontal scroll effect.
class TrendingTracks extends ConsumerWidget {
  const TrendingTracks({super.key, required this.tracks, this.genreId});
  final List<Track> tracks;
  final String? genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Split tracks into pages of 3 for the horizontal paged layout.
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
                      child: track.artworkUrl.startsWith('http')
                          ? Image.network(
                              track.artworkUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[800],
                              ),
                            )
                          : Image.asset(
                              track.artworkUrl.isNotEmpty
                                  ? track.artworkUrl
                                  : 'assets/images/placeholder.png',
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
                    trailing: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => TrackOptionsModal(track: track),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      final playerState = ref.read(playerStateProvider);
                      final isThisTrackLoaded =
                          playerState.currentTrack?.id == track.id;

                      if (isThisTrackLoaded) {
                        ref
                            .read(playerStateProvider.notifier)
                            .togglePlayPause();
                      } else {
                        ref.read(queueStateProvider.notifier).playQueue(
                              tracks: tracks,
                              initialIndex: tracks.indexOf(track),
                              context: QueueContext(
                                type: QueueSource.trending,
                                sourceId: genreId,
                              ),
                            );
                      }
                    },
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
