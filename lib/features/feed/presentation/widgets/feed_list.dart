import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_providers.dart';
import 'feed_card.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/feed_item.dart';

enum FeedTab { discover, following }

class FeedList extends ConsumerStatefulWidget {
  final FeedTab tab;
  const FeedList({super.key, required this.tab});

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> {
  final _pageController = PageController();
  bool _previewMode = false;
  String? _nowPlayingTrackId;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _activatePreviewMode(Track track) {
    setState(() {
      _previewMode = true;
      _nowPlayingTrackId = null;
    });
    final playerState = ref.read(playerStateProvider);
    final isAlreadyLoaded = playerState.currentTrack?.id == track.id;
    if (isAlreadyLoaded) {
      ref.read(playerStateProvider.notifier).togglePlayPause();
    } else {
      ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
    }
  }

  void _deactivatePreviewMode() {
    setState(() => _previewMode = false);
    ref.read(playerStateProvider.notifier).togglePlayPause();
  }

  void _onBottomInfoPlay(String trackId) {
    setState(() {
      _nowPlayingTrackId = trackId;
      _previewMode = false;
    });
  }

  void _playTrack(Track track) {
    final playerState = ref.read(playerStateProvider);
    if (playerState.currentTrack?.id == track.id) return;
    ref.read(playerStateProvider.notifier).loadAndPlayQueue([track]);
  }

  Track _trackFromFollowing(FeedItemEntity item) => Track(
    id: item.track.id,
    userId: item.user.id,
    title: item.track.title,
    artist: item.user.displayName,
    artistPfp: item.user.avatar,
    audioUrl: item.track.audioUrl,
    coverImage: item.track.coverUrl,
    duration: Duration(seconds: item.track.duration),
    createdAt: item.createdAt,
    playCount: item.track.playCount,
    likeCount: item.track.likeCount,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.tab == FeedTab.discover) {
      final async = ref.watch(discoverFeedProvider);
      return async.when(
        loading: () => const Center(
          key: Key('feed_list_discover_loading'),
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (e, _) => Center(
          key: const Key('feed_list_discover_error'),
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        data: (items) => PageView.builder(
          key: const Key('feed_list_discover_pageview'),
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          onPageChanged: (index) {
            if (_previewMode) {
              _playTrack(_trackFromFollowing(items[index]));
            }
          },
          itemBuilder: (context, index) => GestureDetector(
            key: Key('feed_list_discover_gesture_$index'),
            onTap: () {
              if (_previewMode) {
                _deactivatePreviewMode();
              } else {
                _activatePreviewMode(_trackFromFollowing(items[index]));
              }
            },
            child: FeedCard(
              key: Key('feed_list_discover_card_$index'),
              item: items[index],
              tab: widget.tab,
              previewMode: _previewMode,
              nowPlayingTrackId: _nowPlayingTrackId,
              onPlay: () => _onBottomInfoPlay(items[index].track.id),
              fullScreen: true,
            ),
          ),
        ),
      );
    }

    final async = ref.watch(followingFeedProvider);
    return async.when(
      loading: () => const Center(
        key: Key('feed_list_following_loading'),
        child: CircularProgressIndicator(color: Colors.orange),
      ),
      error: (e, _) => Center(
        key: const Key('feed_list_following_error'),
        child: Text(
          e.toString(),
          style: const TextStyle(color: Colors.white54),
        ),
      ),
      data: (items) => PageView.builder(
        key: const Key('feed_list_following_pageview'),
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        onPageChanged: (index) {
          if (_previewMode) {
            _playTrack(_trackFromFollowing(items[index]));
          }
        },
        itemBuilder: (context, index) => GestureDetector(
          key: Key('feed_list_following_gesture_$index'),
          onTap: () {
            if (_previewMode) {
              _deactivatePreviewMode();
            } else {
              _activatePreviewMode(_trackFromFollowing(items[index]));
            }
          },
          child: FeedCard(
            key: Key('feed_list_following_card_$index'),
            item: items[index],
            tab: widget.tab,
            previewMode: _previewMode,
            nowPlayingTrackId: _nowPlayingTrackId,
            onPlay: () => _onBottomInfoPlay(items[index].track.id),
          ),
        ),
      ),
    );
  }
}