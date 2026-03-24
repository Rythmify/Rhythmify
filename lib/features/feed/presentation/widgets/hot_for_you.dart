import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

import '../providers/home_providers.dart';
import 'dart:ui';

/// Widget that renders the "Hot For You" section.
///
/// This widget:
/// - Observes [hotTracksProvider]
/// - Displays loading indicator while fetching data
/// - Displays error message if request fails
/// - Shows a single featured track when data is available
class HotForYouSection extends ConsumerWidget {
  const HotForYouSection({super.key});

  /// Builds the Hot For You section UI.
  ///
  /// Parameters:
  /// - context: Build context for rendering UI
  /// - ref: Riverpod reference used to watch providers
  ///
  /// Returns:
  /// - A widget that displays loading, error, or a featured track card
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHotTracks = ref.watch(hotTracksProvider);
    return Column(
      key: const Key('hot_for_you_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18, left: 21),
          child: Text("Hot For You 🔥", style: AppTheme.titleLarge),
        ),

        asyncHotTracks.when(
          loading: () => const Center(
            key: Key('hot_for_you_loading'),
            child: CircularProgressIndicator(color: AppTheme.primaryBrand),
          ),

          error: (e, _) => Text(
            e.toString(),
            key: const Key('hot_for_you_error_text'),
            style: AppTheme.bodyMedium,
          ),

          data: (tracks) {
            if (tracks.isEmpty) {
              return const SizedBox();
            }

            final track = tracks.first;

            return HotForYouCard(track: track);
          },
        ),
      ],
    );
  }
}

/// Card widget that displays a featured "Hot For You" track.
///
/// This widget is responsible for:
/// - Displaying track artwork, title, and artist
/// - Handling play/pause interaction via player state
/// - Showing animated vinyl rotation when playing
///
/// It interacts with:
/// - [playerStateProvider] for playback state
/// - [Track] entity from domain layer
class HotForYouCard extends ConsumerStatefulWidget {
  /// The track to be displayed in the card.
  final Track track;

  const HotForYouCard({super.key, required this.track});

  @override
  ConsumerState<HotForYouCard> createState() => _HotForYouCardState();
}

class _HotForYouCardState extends ConsumerState<HotForYouCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Initializes animation controller for vinyl rotation effect.
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  /// Builds the UI for the Hot For You card.
  ///
  /// This method:
  /// - Reads player state from Riverpod
  /// - Controls animation based on playback status
  /// - Displays track metadata and playback controls
  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);

    final isPlaying = playerState.status == PlayerStatus.playing;

    final isThisTrack = playerState.currentTrack?.id == widget.track.id;

    if (isPlaying && isThisTrack) {
      _controller.repeat();
    } else {
      _controller.stop();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        key: Key('hot_track_card_${widget.track.id}'),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),

          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(widget.track.artworkUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: FrostedGlassBox(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    buildAlbum(),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.track.title,
                            key: const Key('hot_for_you_track_title_text'),
                            style: AppTheme.bodyNormal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.track.artist,
                            key: const Key('hot_for_you_track_artist_text'),
                            style: AppTheme.bodyNormal.copyWith(
                              color: AppTheme.semiWhite,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      key: const Key('hot_for_you_play_icon_button'),
                      iconSize: 60,
                      icon: Icon(
                        isPlaying && isThisTrack
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: AppTheme.textPrimary,
                      ),
                      onPressed: () {
                        if (isThisTrack) {
                          ref
                              .read(playerStateProvider.notifier)
                              .togglePlayPause();
                        } else {
                          ref
                              .read(playerStateProvider.notifier)
                              .loadAndPlayQueue([widget.track]);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: AppTheme.semiWhite,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "${formatCount(widget.track.likeCount)} people liked your track",
                      key: const Key('hot_for_you_like_count_text'),
                      style: AppTheme.bodyNormal.copyWith(
                        fontSize: 12,
                        color: AppTheme.semiWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the album + rotating vinyl UI component.
  ///
  /// Returns:
  /// - A widget showing static album cover and animated CD effect
  Widget buildAlbum() {
    return SizedBox(
      key: Key('hot_album_${widget.track.id}'),
      width: 100,
      height: 70,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 30,
            child: RotationTransition(
              turns: _controller,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(widget.track.artworkUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 65,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.7),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[900],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(widget.track.artworkUrl, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats large numbers into human-readable strings (K, M).
  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Frosted glass effect container used for UI styling.
///
/// This widget applies:
/// - Background blur effect
/// - Semi-transparent overlay
/// - Rounded corners
///
/// It is purely presentational and used for visual enhancement.
class FrostedGlassBox extends StatelessWidget {
  final Widget child;

  const FrostedGlassBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const Key('frosted_glass_repaint_boundary'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: const SizedBox.shrink(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                border: Border.all(
                  color: Colors.white.withAlpha(50),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
