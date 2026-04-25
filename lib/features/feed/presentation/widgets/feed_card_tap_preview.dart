import 'package:flutter/material.dart';
import '../../domain/entities/feed_item.dart';
import '../../../../core/domain/entities/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';

class TapToPreview extends ConsumerStatefulWidget {
  final FeedItemEntity item;

  const TapToPreview({super.key, required this.item});

  @override
  ConsumerState<TapToPreview> createState() => TapToPreviewState();
}

class TapToPreviewState extends ConsumerState<TapToPreview> {
  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final isThisTrackPlaying =
        playerState.currentTrack?.id == widget.item.track.id &&
        playerState.status == PlayerStatus.playing;

    return isThisTrackPlaying
        ? const SizedBox.shrink(key: Key('tap_to_preview_hidden'))
        : _buildPrompt();
  }

  void toggle() {
    final playerState = ref.read(playerStateProvider);
    final isThisTrackLoaded =
        playerState.currentTrack?.id == widget.item.track.id;

    if (isThisTrackLoaded) {
      ref.read(playerStateProvider.notifier).togglePlayPause();
    } else {
      final track = Track(
        id: widget.item.track.id,
        userId: widget.item.user.id,
        title: widget.item.track.title,
        artist: widget.item.user.displayName,
        artistPfp: widget.item.user.avatar,
        audioUrl: widget.item.track.audioUrl,
        coverImage: widget.item.track.coverUrl,
        duration: Duration(seconds: widget.item.track.duration),
        createdAt: widget.item.createdAt,
        playCount: widget.item.track.playCount,
        likeCount: widget.item.track.likeCount,
      );
      ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
    }
  }

  Widget _buildPrompt() {
    return const Column(
      key: Key('tap_to_preview_column'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key: Key('tap_to_preview_text'),
          'Tap to preview',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Icon(
          key: Key('tap_to_preview_icon'),
          Icons.volume_off,
          color: Colors.white54,
          size: 36,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}