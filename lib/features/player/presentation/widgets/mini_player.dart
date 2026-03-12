import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart'; // Keep your theme imports
import '../providers/player_provider.dart';
import '../../domain/entities/player_state.dart';
import '../../../track/presentation/providers/track_interaction_provider.dart';

class MiniPlayer extends ConsumerWidget {
  final VoidCallback? onTap; // Changed from VoidCrossCallback to standard VoidCallback

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ONLY rebuilds when the song changes, not when the timer ticks!
    final track = ref.watch(playerStateProvider.select((state) => state.currentTrack));

    if (track == null) return const SizedBox.shrink();

    return Padding(
      // Add a little padding so it floats nicely at the bottom
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.only(left: 8, right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF28282A), // The dark grey from your image
            borderRadius: BorderRadius.circular(32), // Creates the perfect pill shape
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(
            children: [
              // ==========================================
              // Left: Isolated Animated Progress Play Button
              // ==========================================
              const MiniPlayerProgressButton(),
              const SizedBox(width: 12),

              // ==========================================
              // Center: Track Info
              // ==========================================
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // Right: Social Actions
              // ==========================================
              IconButton(
                icon: Icon(track.isArtistFollowed ? Icons.person_add_alt_1 : Icons.person_add_alt), 
                
                color: track.isArtistFollowed ? AppTheme.primaryBrand : Colors.white,
                onPressed: () {
                 // ref.read(trackInteractionProvider).handleToggleFollow(track.artistId, track.isArtistFollowed);
                },
              ),
              IconButton(
                icon: Icon(track.isLiked ? Icons.favorite : Icons.favorite_border),
                color: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                onPressed: () {
                  ref.read(trackInteractionProvider).handleToggleLike(track.id, track.isLiked);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class MiniPlayerProgressButton extends ConsumerWidget {
  const MiniPlayerProgressButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the rapidly changing timer
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));
    final status = ref.watch(playerStateProvider.select((state) => state.status));

    final isPlaying = status == PlayerStatus.playing;
    
    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return GestureDetector(
      onTap: () => ref.read(playerStateProvider.notifier).togglePlayPause(),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The orange progress arc
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrand), // Your brand orange
              backgroundColor: Colors.black87, // Dark grey background track
            ),
            // The white play/pause button
            Padding(
              padding: const EdgeInsets.all(4.5), // Shrinks the white circle inside the progress ring
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}