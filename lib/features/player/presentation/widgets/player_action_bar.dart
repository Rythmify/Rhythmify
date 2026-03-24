import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../track/presentation/providers/track_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// A horizontal bar providing secondary track actions.
///
/// Includes like count, comments, sharing, and playlist management.
///
/// Depends on [trackDetailsProvider].
class PlayerActionBar extends ConsumerWidget {
  /// The ID of the track for which to display actions.
  final String trackId;

  const PlayerActionBar({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackDetailsProvider(trackId));

    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(bottom: 36, top: 25, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                key: Key('player_action_bar_favorite_icon'),
                Icons.favorite_border,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              trackAsync.when(
                data: (track) => Text(
                  Formatters.formatCount(track.likeCount),
                  key: const Key('player_action_bar_like_count_text'),
                  style: AppTheme.bodyNormal,
                ),
                loading: () => const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    key: Key('player_action_bar_like_count_loading_indicator'),
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                error: (a, b) => const Text(
                  '0',
                  key: Key('player_action_bar_like_count_error_text'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Icon(
            key: Key('player_action_bar_comment_icon'),
            Icons.chat_bubble_outline,
            color: Colors.white,
          ),
          const Icon(
            key: Key('player_action_bar_share_icon'),
            Icons.share_outlined,
            color: Colors.white,
          ),
          const Icon(
            key: Key('player_action_bar_playlist_icon'),
            Icons.playlist_play,
            color: Colors.white,
          ),
          const Icon(
            key: Key('player_action_bar_more_icon'),
            Icons.more_vert,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
