import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../widgets/player_controls.dart';

class FullPlayerPage extends ConsumerWidget {
  const FullPlayerPage({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final track = playerState.currentTrack;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: Text("No track playing", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing', style: TextStyle(color: Colors.white, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Artwork
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  track.artworkUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (a,b,c) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white54, size: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title & Artist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.artist,
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    track.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                  ),
                  onPressed: () {
                    // Trigger like use case
                  },
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Progress Bar
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppTheme.primaryBrand,
                inactiveTrackColor: Colors.grey[800],
                thumbColor: AppTheme.primaryBrand,
              ),
              child: Slider(
                min: 0,
                max: playerState.duration.inMilliseconds.toDouble() > 0 
                    ? playerState.duration.inMilliseconds.toDouble() 
                    : 1,
                value: playerState.position.inMilliseconds.toDouble().clamp(
                    0.0, 
                    playerState.duration.inMilliseconds.toDouble() > 0 ? playerState.duration.inMilliseconds.toDouble() : 1.0),
                onChanged: (value) {
                  ref.read(playerStateProvider.notifier).seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            
            // Time Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(playerState.position), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text(_formatDuration(playerState.duration), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Controls
            const PlayerControls(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
