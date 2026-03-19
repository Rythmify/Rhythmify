import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

import '../providers/home_providers.dart';
import 'dart:ui';

// =====================
//  HOT FOR YOU SECTION
// =====================

class HotForYouSection extends ConsumerWidget {
  const HotForYouSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHotTracks = ref.watch(hotTracksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18, left: 21),
          child: Text("Hot For You 🔥", style: AppTheme.titleLarge),
        ),

        asyncHotTracks.when(
          loading: () => const Center(
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

// ==================
//  HOT FOR YOU CARD
// ==================

class HotForYouCard extends ConsumerStatefulWidget {
  final Track track;

  const HotForYouCard({super.key, required this.track});

  @override
  ConsumerState<HotForYouCard> createState() => _HotForYouCardState();
}

class _HotForYouCardState extends ConsumerState<HotForYouCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);

    final isPlaying = playerState.status == PlayerStatus.playing;

    final isThisTrack = playerState.currentTrack?.id == widget.track.id;

    // Control rotation
    if (isPlaying && isThisTrack) {
      _controller.repeat();
    } else {
      _controller.stop();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),

          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(widget.track.artworkUrl),
            fit: BoxFit.cover,
          ),
        ),
        child:
            /// Content
            FrostedGlassBox(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Album + CD
                        buildAlbum(),

                        const SizedBox(width: 20),

                        // Title + Artist
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

                        // Play Button
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

                    //like text
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: AppTheme.primaryBrand,
                          size: 16,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "${formatCount(widget.track.playCount)} people liked your track",
                          key: const Key('hot_for_you_like_count_text'),
                          style: AppTheme.labelSmall,
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

  //cd+track design
  Widget buildAlbum() {
    return SizedBox(
      width: 100,
      height: 70,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          //rotating cd
          Positioned(
            left: 30,
            child: RotationTransition(
              turns: _controller,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // classic vinyl
                ),
                child: Center(
                  child: Container(
                    width: 22, // center hole image
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

          // static track cover box
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

  //number formatting
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

//frosted glass(blurry background effect)
class FrostedGlassBox extends StatelessWidget {
  final Widget child;

  const FrostedGlassBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withAlpha(150), // subtle tint
          child: child,
        ),
      ),
    );
  }
}
