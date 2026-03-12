import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';

class MiniPlayer extends ConsumerWidget {
  final VoidCrossCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final track = playerState.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Artwork
            Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: Image.asset(
                track.artworkUrl,
                fit: BoxFit.cover,
                errorBuilder: (a,b,c) => const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            
            // Controls
            IconButton(
              icon: Icon(
                playerState.status == PlayerStatus.playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                ref.read(playerStateProvider.notifier).togglePlayPause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {
                ref.read(playerStateProvider.notifier).skipToNext();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

typedef VoidCrossCallback = void Function();