import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

import '../providers/home_providers.dart';
import 'dart:ui';

class HotForYouSection extends ConsumerWidget {
  const HotForYouSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHotForYou = ref.watch(hotForYouProvider);

    return Column(
      key: const Key('hot_for_you_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18, left: 21),
          child: Text("Hot For You 🔥", style: AppTheme.titleLarge),
        ),
        asyncHotForYou.when(
          loading: () => const Center(
            key: Key('hot_for_you_loading'),
            child: CircularProgressIndicator(color: AppTheme.primaryBrand),
          ),
          error: (e, _) => Text(
            e.toString(),
            key: const Key('hot_for_you_error_text'),
            style: AppTheme.bodyMedium,
          ),
          data: (hotForYou) => HotForYouCard(track: hotForYou.track),
        ),
      ],
    );
  }
}

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

  String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

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
