import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_item.dart';
import 'feed_card_bottom_info.dart';
import 'feed_card_side_actions.dart';
import 'feed_card_cover.dart';
import 'feed_list.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

/// A full-screen feed card that displays a single [FeedItemEntity].
///
/// Composes [FeedCardCover], [FeedCardSideActions], and [FeedCardBottomInfo]
/// into a stacked layout. Overlays contextual UI based on the current
/// playback state:
/// - "Tap to preview" when the track is not playing and not in preview mode.
/// - "Now Playing" when this card's track is the active player track.
///
/// The [fullScreen] flag switches [FeedCardCover] between its compact
/// and full-screen rendering modes.
class FeedCard extends ConsumerWidget {
  final FeedItemEntity item;

  /// The feed tab this card belongs to, used to derive [_bottomLabel].
  final FeedTab tab;

  /// Whether the card is currently in preview (audio playing inline) mode.
  final bool previewMode;

  /// The ID of the track currently loaded in the player, if any.
  final String? nowPlayingTrackId;

  /// Callback invoked when the user taps the play button.
  final VoidCallback? onPlay;

  /// Whether to render the cover in full-screen mode.
  final bool fullScreen;

  const FeedCard({
    super.key,
    required this.item,
    required this.tab,
    required this.previewMode,
    this.nowPlayingTrackId,
    this.onPlay,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isThisTrackNowPlaying =
        playerState.currentTrack?.id == item.track.id &&
        (playerState.status == PlayerStatus.playing) &&
        !previewMode;

    final showTapToPreview = !previewMode && !isThisTrackNowPlaying;

    return Stack(
      key: const Key('feed_card_stack'),
      fit: StackFit.expand,
      children: [
        FeedCardCover(
          key: const Key('feed_card_cover'),
          coverUrl: item.track.coverUrl,
          fullScreen: fullScreen,
        ),
        // Bottom gradient to improve legibility of the bottom info section
        const DecoratedBox(
          key: Key('feed_card_gradient'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xD9000000)],
              stops: [0.45, 1.0],
            ),
          ),
        ),
        // Dark overlay that fades out when the card is active or in preview
        IgnorePointer(
          child: AnimatedOpacity(
            key: const Key('feed_card_animated_opacity'),
            duration: const Duration(milliseconds: 300),
            opacity: (previewMode || isThisTrackNowPlaying) ? 0.0 : 0.45,
            child: const ColoredBox(
              key: Key('feed_card_dark_overlay'),
              color: Colors.black,
              child: SizedBox.expand(),
            ),
          ),
        ),
        // Prompt shown when the track has not been previewed yet
        if (showTapToPreview)
          const IgnorePointer(
            child: Center(
              key: Key('feed_card_tap_to_preview_center'),
              child: Column(
                key: Key('feed_card_tap_to_preview_column'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key: Key('feed_card_tap_to_preview_text'),
                    'Tap to preview',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    key: Key('feed_card_tap_to_preview_icon'),
                    Icons.volume_off,
                    color: Colors.white54,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        // Indicator shown when this card's track is actively playing
        if (isThisTrackNowPlaying)
          const IgnorePointer(
            child: Center(
              key: Key('feed_card_now_playing_center'),
              child: Column(
                key: Key('feed_card_now_playing_column'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key: Key('feed_card_now_playing_text'),
                    'Now Playing',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    key: Key('feed_card_now_playing_icon'),
                    Icons.equalizer,
                    color: Colors.white54,
                    size: 36,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        Positioned(
          key: const Key('feed_card_side_actions_positioned'),
          right: 12,
          bottom: 200,
          child: FeedCardSideActions(
            key: const Key('feed_card_side_actions'),
            item: item,
          ),
        ),
        Positioned(
          key: const Key('feed_card_bottom_positioned'),
          left: 12,
          right: 12,
          bottom: 62,
          child: Column(
            key: const Key('feed_card_bottom_column'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                key: const Key('feed_card_bottom_label_padding'),
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  key: const Key('feed_card_bottom_label_text'),
                  _bottomLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              FeedCardBottomInfo(
                key: const Key('feed_card_bottom_info'),
                item: item,
                onPlay: onPlay,
                showProgress: previewMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Derives the contextual label shown above the bottom info section.
  ///
  /// Priority order:
  /// 1. [FeedItemEntity.discoverLabel] if set (custom backend label).
  /// 2. `'Discovered for you'` for discover tab items without a label.
  /// 3. `'<displayName> reposted'` for repost activity.
  /// 4. `'<displayName> posted'` for original posts.
  String get _bottomLabel {
    if (item.discoverLabel != null) return item.discoverLabel!;
    if (tab == FeedTab.discover) return 'Discovered for you';
    if (item.type == 'repost') return '${item.user.displayName} reposted';
    return '${item.user.displayName} posted';
  }
}
