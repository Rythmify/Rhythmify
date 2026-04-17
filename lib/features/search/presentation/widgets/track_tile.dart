import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/utils/formatters.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../track/presentation/widgets/bottom_sheets/track_options_modal.dart';

/// A reusable track row showing artwork, title, artist, and formatted duration.
/// Used across the search results tabs (Tracks, All) and any other feature that lists tracks.
/// [onTap] is a placeholder — will trigger the player once routing is set up.
class TrackTile extends ConsumerWidget {
  const TrackTile({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('track_tile_${track.id}'),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: track.artworkUrl.startsWith('http')
            ? Image.network(
                track.artworkUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(width: 50, height: 50, color: Colors.grey[800]),
              )
            : Image.asset(
                track.artworkUrl.isNotEmpty
                    ? track.artworkUrl
                    : 'assets/images/placeholder.png',
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
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Icon(Icons.more_vert, color: Colors.white),
        ),
      ),
      onTap: () {
        final playerState = ref.read(playerStateProvider);
        final isThisTrackLoaded = playerState.currentTrack?.id == track.id;

        if (isThisTrackLoaded) {
          ref.read(playerStateProvider.notifier).togglePlayPause();
        } else {
          ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
        }
      },
    );
  }
}
