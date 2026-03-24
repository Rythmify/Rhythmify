import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../../../track/presentation/providers/track_interaction_provider.dart';
import 'mini_player_progress_button.dart';

class MiniPlayer extends ConsumerWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ONLY rebuilds when the song changes -> not when the timer ticks
    final track = ref.watch(
      playerStateProvider.select((state) => state.currentTrack),
    );

    if (track == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 11.0),
      child: GestureDetector(
        key: const Key('player_mini_player_gesture_detector'),
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.only(left: 8, right: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 33, 33, 39),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withValues(alpha: 0.3),
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              // ===============================
              //  Animated Progress Play Button
              // ===============================
              const SizedBox(width: 5),
              const MiniPlayerProgressButton(),
              const SizedBox(width: 16),

              // ============
              //  Track Info
              // ============
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      key: const Key('player_mini_player_title_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.miniPlayerFont1,
                    ),
                    Text(
                      track.artist,
                      key: const Key('player_mini_player_artist_text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.miniPlayerFont2,
                    ),
                  ],
                ),
              ),

              // ================
              //  Social Actions
              // ================
              IconButton(
                key: const Key('player_mini_player_follow_icon_button'),
                icon: Icon(
                  track.isArtistFollowed
                      ? Icons.person_add_alt_1
                      : Icons.person_add_alt,
                ),
                color: track.isArtistFollowed
                    ? AppTheme.primaryBrand
                    : Colors.white,
                onPressed: () {},
              ),
              IconButton(
                key: const Key('player_mini_player_like_icon_button'),
                icon: Icon(
                  track.isLiked ? Icons.favorite : Icons.favorite_border,
                ),
                color: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                onPressed: () {
                  ref
                      .read(trackInteractionProvider)
                      .handleToggleLike(track.id, track.isLiked);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
