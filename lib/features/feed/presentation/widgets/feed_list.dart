import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_providers.dart';
import 'feed_card.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/feed_item.dart';
import '../../../player/domain/entities/player_state.dart';

enum FeedTab { discover, following }

class FeedList extends ConsumerStatefulWidget {
  final FeedTab tab;
  const FeedList({super.key, required this.tab});

  @override
  ConsumerState<FeedList> createState() => FeedListState();
}

class FeedListState extends ConsumerState<FeedList> {
  final _pageController = PageController();

  bool _previewMode = false;
  String? _nowPlayingTrackId;
  String? _pendingTrackId;
  String? _rawPendingTrackId;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void resetPreview() {
    setState(() {
      _previewMode = false;
      _nowPlayingTrackId = null;
    });
  }

  // Preview mode

  void _activatePreviewMode(Track track) {
    setState(() {
      _previewMode = true;
      _nowPlayingTrackId = null;
    });

    ref.read(playerStateProvider.notifier).loadAndPlayPreview(track);
  }

  void _deactivatePreviewMode() {
    setState(() => _previewMode = false);
    final playerState = ref.read(playerStateProvider);
    if (playerState.status == PlayerStatus.playing) {
      ref.read(playerStateProvider.notifier).togglePlayPause();
    }
  }

  // Bottom-info full play

  /// Called by FeedCardBottomInfo when user taps title or play circle.
  /// Sets pending-expand so the sheet opens as soon as the player confirms
  /// the track — handles both instant (already loaded) and async (new track).
  void _onBottomInfoPlay(String trackId) {
    _rawPendingTrackId = trackId;

    setState(() {
      _nowPlayingTrackId = trackId;
      _previewMode = false;
      _pendingTrackId = trackId;
    });
  }

  void _tryExpandSheet({int attempts = 0}) {
    if (!mounted) return;
    if (attempts > 20) return;

    final notifier = playerSheetNotifier.value;
    if (notifier != null) {
      notifier();

      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) notifier();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryExpandSheet(attempts: attempts + 1);
      });
    }
  }

  //Scroll while preview

  void _onPageChangedInPreviewMode(Track track) {
    // Just load and play the new track; preview mode stays active.
    ref.read(playerStateProvider.notifier).loadAndPlayPreview(track);
    // Keep _nowPlayingTrackId null — this is preview, not full play.
  }

  // Helpers

  Track _trackFrom(FeedItemEntity item, {bool preview = false}) => Track(
    id: item.track.id,
    userId: item.user.id,
    title: item.track.title,
    artist: item.user.displayName,
    artistPfp: item.user.avatar,
    // Preview uses previewUrl, full play uses streamUrl ?? audioUrl
    audioUrl: preview
        ? (item.track.previewUrl ?? item.track.streamUrl ?? item.track.audioUrl)
        : (item.track.streamUrl ?? item.track.audioUrl),
    coverImage: item.track.coverUrl,
    duration: Duration(seconds: item.track.duration),
    createdAt: item.createdAt,
    playCount: item.track.playCount,
    likeCount: item.track.likeCount,
  );
  @override
  Widget build(BuildContext context) {
    ref.listen(playerStateProvider, (prev, next) {
      final currentId = next.currentTrack?.id;
      final pendingId = _rawPendingTrackId ?? _pendingTrackId;

      if (pendingId != null && currentId == pendingId) {
        _tryExpandSheet(); // <-- replaces playerSheetNotifier.value?.call()
        _rawPendingTrackId = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _pendingTrackId = null;
            });
          }
        });
      }

      if (_nowPlayingTrackId != null && pendingId == null) {
        final stoppedOrPaused =
            next.status == PlayerStatus.paused ||
            next.status == PlayerStatus.stopped;
        if (stoppedOrPaused || currentId != _nowPlayingTrackId) {
          setState(() {
            _nowPlayingTrackId = null;
            if (next.currentTrack != null && stoppedOrPaused) {
              _previewMode = false;
            }
          });
        }
      }
    });

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
              _onPageChangedInPreviewMode(
                _trackFrom(items[index], preview: true),
              );
            } else if (_nowPlayingTrackId != null) {
              setState(() => _nowPlayingTrackId = null);
            }
          },
          itemBuilder: (context, index) => Stack(
            key: Key('feed_list_discover_gesture_$index'),
            children: [
              FeedCard(
                key: Key('feed_list_discover_card_$index'),
                item: items[index],
                tab: widget.tab,
                previewMode: _previewMode,
                nowPlayingTrackId: _nowPlayingTrackId,
                onPlay: () => _onBottomInfoPlay(items[index].track.id),
                fullScreen: true,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 350,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_previewMode) {
                      _deactivatePreviewMode();
                    } else {
                      _activatePreviewMode(
                        _trackFrom(items[index], preview: true),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    //Following tab
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
            _onPageChangedInPreviewMode(
              _trackFrom(items[index], preview: true),
            );
          } else if (_nowPlayingTrackId != null) {
            setState(() => _nowPlayingTrackId = null);
          }
        },
        itemBuilder: (context, index) => Stack(
          key: Key('feed_list_following_gesture_$index'),
          children: [
            FeedCard(
              key: Key('feed_list_following_card_$index'),
              item: items[index],
              tab: widget.tab,
              previewMode: _previewMode,
              nowPlayingTrackId: _nowPlayingTrackId,
              onPlay: () => _onBottomInfoPlay(items[index].track.id),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 350,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_previewMode) {
                    _deactivatePreviewMode();
                  } else {
                    _activatePreviewMode(
                      _trackFrom(items[index], preview: true),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
