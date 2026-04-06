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

/// The main immersive playback page of the application.
///
/// This page displays the full-screen player with artwork, controls, and
/// metadata. It reacts to changes in [playerStateProvider].

class FullPlayerPage extends ConsumerWidget {
  /// Callback triggered when the player is collapsed or dismissed.
  final VoidCallback? onCollapse;

  const FullPlayerPage({super.key, this.onCollapse});

  /// Navigates to the "Behind the Track" page for additional metadata.

  // void _triggerNavigation(BuildContext context, String trackId) {
  //   if (onCollapse != null) onCollapse!();
  //   context.pushNamed('behindTheTrack', pathParameters: {'trackId': trackId});
  // }
  void _triggerNavigation(BuildContext context, String trackId) {
    // 1. Debug prints to catch the culprit
    print('=== DEBUG: NAVIGATING TO BEHIND THE TRACK ===');
    print('Track ID passed: "$trackId"');

    if (onCollapse != null) onCollapse!();

    // 2. Encode the ID to safely handle ANY slashes or weird characters
    // This prevents GoRouter from thinking a slash is a new route path.
    final safeTrackId = Uri.encodeComponent(trackId);

    // 3. Push using the exact path to avoid cross-branch named route deadlocks.
    // (Using pushNamed from a root FullPlayerPage into a tabbed shell can sometimes freeze)
    context.push('/home/behind-the-track/$safeTrackId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the current track to avoid rebuilding the entire scaffold on progress updates.
    final trackInfo = ref.watch(
      playerStateProvider.select((state) => state.currentTrack),
    );

    if (trackInfo == null) {
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
        onTap: () => ref.read(playerStateProvider.notifier).togglePlayPause(),
        child: Stack(
          children: [
            Positioned.fill(
              child: ScrollingArtworkBackground(
                artworkUrl: trackInfo.artworkUrl,
              ),
            ),

            const Positioned.fill(child: PlaybackOverlayControls()),
            Positioned(
              top: 60,
              left: 16,
              child: TrackInfoBox(
                trackInfo: trackInfo,
                onNavigateBehindTrack: () =>
                    _triggerNavigation(context, trackInfo.id),
              ),
            ),

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
                      icon: Icon(
                        trackInfo.isArtistFollowed
                            ? Icons.person_add_alt_1
                            : Icons.person_add_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PlayerProgressBar(),
                  const SizedBox(height: 40),
                  const FloatingCommentBar(),
                  const SizedBox(height: 40),
                  PlayerActionBar(trackId: trackInfo.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
