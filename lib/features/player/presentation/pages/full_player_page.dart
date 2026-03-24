import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../widgets/scrolling_artwork_background.dart';
import '../widgets/playback_overlay_controls.dart';
import '../widgets/track_info_box.dart';
import '../widgets/player_progress_bar.dart';
import 'package:rythmify/features/comments/presentation/widgets/floating_comment_bar.dart';
import '../widgets/player_action_bar.dart';
import 'package:go_router/go_router.dart';

class FullPlayerPage extends ConsumerWidget {
  final VoidCallback? onCollapse;
  const FullPlayerPage({super.key, this.onCollapse});

  void _triggerNavigation(BuildContext context, String trackId) {
    // Collapse the player
    if (onCollapse != null) onCollapse!();
    context.pushNamed('behindTheTrack', pathParameters: {'trackId': trackId});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(
      playerStateProvider.select((state) => state.currentTrack),
    );

    if (summary == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No track playing",
            key: Key('player_full_page_no_track_text'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        key: const Key('player_full_page_toggle_play_pause_gesturedetector'),
        // Tapping anywhere on the background toggles play/pause
        onTap: () => ref.read(playerStateProvider.notifier).togglePlayPause(),
        child: Stack(
          children: [
            // ==========================================
            // LAYER 1: Optimized Scrolling Background
            // ==========================================
            Positioned.fill(
              child: ScrollingArtworkBackground(artworkUrl: summary.artworkUrl),
            ),

            // ==========================================
            // LAYER 2: Playback Controls Overlay
            // ==========================================
            const Positioned.fill(child: PlaybackOverlayControls()),

            // ==========================================
            // LAYER 3: Top Left Track Info
            // ==========================================
            Positioned(
              top: 60,
              left: 16,
              child: TrackInfoBox(
                summary: summary,
                onNavigateBehindTrack: () =>
                    _triggerNavigation(context, summary.id),
              ),
            ),

            // ==========================================
            // LAYER 4: Top Right Controls
            // ==========================================
            Positioned(
              top: 60,
              right: 8,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      key: const Key('player_full_page_collapse_iconbutton'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                        size: 20,
                      ),

                      onPressed: onCollapse ?? () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      key: const Key('player_full_page_add_person_iconbutton'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        // Handle user add
                      },
                    ),
                  ),
                ],
              ),
            ),

            // =================
            //  Bottom Elements
            // =================
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PlayerProgressBar(),
                  const SizedBox(height: 40),
                  const FloatingCommentBar(),
                  const SizedBox(height: 40),
                  PlayerActionBar(trackId: summary.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
