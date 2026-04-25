import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/scrolling_artwork_background.dart';
import '../widgets/playback_overlay_controls.dart';
import '../widgets/track_info_box.dart';
import 'package:rythmify/features/comments/presentation/widgets/floating_comment_bar.dart';
import '../widgets/player_action_bar.dart';
import '../widgets/waveform/track_waveform_visualizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/entities/track.dart';

/// The main immersive playback page of the application.
///
/// This page displays the full-screen player with artwork, controls, and
/// metadata. It now supports carousel-style swiping between tracks in the queue.
class FullPlayerPage extends ConsumerStatefulWidget {
  final VoidCallback? onCollapse;

  const FullPlayerPage({super.key, this.onCollapse});

  @override
  ConsumerState<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends ConsumerState<FullPlayerPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final queue = ref.read(queueStateProvider);
    _currentPage = queue.history.length;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _triggerNavigation(BuildContext context, String trackId) {
    if (widget.onCollapse != null) widget.onCollapse!();
    context.pushNamed('behindTheTrack', pathParameters: {'trackId': trackId});
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(queueStateProvider);
    final allTracks = [
      ...queue.history,
      if (queue.currentTrack != null) queue.currentTrack!,
      ...queue.upcomingTracks,
    ];

    if (queue.currentTrack == null || allTracks.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No track playing",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Sync PageController if track changed from outside (e.g. Action Bar)
    final syncIndex = queue.history.length;
    if (_currentPage != syncIndex) {
      final isUserScrolling =
          _pageController.hasClients &&
          (_pageController.position.isScrollingNotifier.value ||
              _pageController.position.pixels %
                      (MediaQuery.of(context).size.width) !=
                  0);

      if (!isUserScrolling) {
        _currentPage = syncIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(syncIndex);
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: allTracks.length,
        onPageChanged: (index) {
          if (index != _currentPage) {
            _currentPage = index;
            ref.read(queueStateProvider.notifier).skipToIndex(index);
          }
        },
        itemBuilder: (context, index) {
          final track = allTracks[index];
          final isCurrent = track.id == queue.currentTrack?.id;

          return _PlayerTrackPage(
            track: track,
            isCurrent: isCurrent,
            onCollapse: widget.onCollapse,
            onNavigateBehindTrack: () => _triggerNavigation(context, track.id),
          );
        },
      ),
    );
  }
}

class _PlayerTrackPage extends ConsumerWidget {
  final Track track;
  final bool isCurrent;
  final VoidCallback? onCollapse;
  final VoidCallback onNavigateBehindTrack;

  const _PlayerTrackPage({
    required this.track,
    required this.isCurrent,
    this.onCollapse,
    required this.onNavigateBehindTrack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      key: ValueKey('player_page_${track.id}'),
      onTap: () {
        if (isCurrent) {
          ref.read(playerStateProvider.notifier).togglePlayPause();
        }
      },
      child: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────────
          Positioned.fill(
            child: ScrollingArtworkBackground(artworkUrl: track.artworkUrl),
          ),

          // ── Overlay Controls (Play/Pause indicator) ──────────────────────
          if (isCurrent)
            const Positioned.fill(child: PlaybackOverlayControls()),

          // ── Track Info ──────────────────────────────────────────────────
          Positioned(
            top: 60,
            left: 16,
            child: TrackInfoBox(
              trackInfo: track,
              onNavigateBehindTrack: onNavigateBehindTrack,
            ),
          ),

          // ── Right Side Actions (Collapse, Follow) ────────────────────────
          Positioned(
            top: 60,
            right: 8,
            child: Column(
              children: [
                _CircularActionButton(
                  icon: Icons.keyboard_arrow_down,
                  onPressed: onCollapse ?? () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                _CircularActionButton(
                  icon: track.isArtistFollowed
                      ? Icons.person_add_alt_1
                      : Icons.person_add_alt,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ── Bottom Controls ──────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Only the current track has an active/interactive waveform
                if (isCurrent)
                  const TrackWaveformVisualizer()
                else
                  const _StaticWaveformPlaceholder(),

                const SizedBox(height: 5),
                if (isCurrent) const FloatingCommentBar(),
                const SizedBox(height: 40),
                if (isCurrent) PlayerActionBar(trackId: track.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _StaticWaveformPlaceholder extends StatelessWidget {
  const _StaticWaveformPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 120,
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Icon(Icons.waves, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
