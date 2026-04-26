import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/providers/queue_provider.dart';

/// [HomeTopTrackCard] is a UI component used in the Home screen to display
/// recently listened tracks in a grid-like layout.
///
/// It features a grey background, track artwork, title, and artist name.
class HomeTopTrackCard extends ConsumerWidget {
  final Track track;
  final VoidCallback? onTap;

  const HomeTopTrackCard({super.key, required this.track, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final currentPlayingId = playerState.currentTrack?.id;
    final isThisTrackLoaded = currentPlayingId == track.id;

    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
          return;
        }
        if (isThisTrackLoaded) {
          ref.read(playerStateProvider.notifier).togglePlayPause();
        } else {
          ref
              .read(queueStateProvider.notifier)
              .playQueue(tracks: [track], initialIndex: 0);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Artwork
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade700, width: 0.7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.3),
                child: _buildArtwork(track.artworkUrl),
              ),
            ),
            const SizedBox(width: 8),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.asset(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.grey, size: 20),
    );
  }
}
