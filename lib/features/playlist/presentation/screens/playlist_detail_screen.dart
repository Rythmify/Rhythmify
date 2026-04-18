// lib/features/playlist/presentation/screens/playlist_detail_screen.dart

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.isOwner = false,
  });

  final String playlistId;
  final bool isOwner;

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistDetailProvider.notifier).init(widget.playlistId);
    });
  }

  Future<void> _fetchAndPlay(PlaylistTrack pt) async {
    try {
      final fullTrack =
          await ref.read(getTrackDetailsUseCaseProvider).call(pt.id);
      await ref
          .read(playerStateProvider.notifier)
          .loadAndPlayQueue([fullTrack], initialIndex: 0);
    } catch (e) {
      debugPrint('[PlaylistDetail] Failed to fetch/play "${pt.title}": $e');
    }
  }

  Future<void> _playAll() async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _shuffle() async {
    final tracks =
        List<PlaylistTrack>.from(ref.read(playlistDetailProvider).tracks)
          ..shuffle();
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _playFrom(int index) async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty || index >= tracks.length) return;
    await _fetchAndPlay(tracks[index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistDetailProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5500)),
        ),
      );
    }

    if (state.playlist == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: Text(
            'Playlist not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final playlist = state.playlist!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('playlist_detail_back_button'),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  PlaylistCoverImage(
                    playlist: playlist,
                    size: 56,
                    borderRadius: 4,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          playlist.subtitleLine,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'By ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              playlist.ownerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Action bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('playlist_detail_like_button'),
                    icon: Icon(
                      playlist.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: playlist.isLiked
                          ? const Color(0xFFFF5500)
                          : Colors.white,
                      size: 24,
                    ),
                    onPressed: () =>
                        ref.read(playlistDetailProvider.notifier).toggleLike(),
                  ),
                  IconButton(
                    key: const Key('playlist_detail_more_button'),
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PlaylistOptionsSheet(
                          playlistId: widget.playlistId,
                          isOwner: widget.isOwner,
                          onConverted: (newType) {
                            switch (newType) {
                              case PlaylistType.album:
                                context.go('/library/albums');
                              case PlaylistType.station:
                                context.go('/library/stations');
                              case PlaylistType.playlist:
                                context.go('/library/playlists');
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    key: const Key('playlist_detail_shuffle_button'),
                    icon: const Icon(
                      Icons.shuffle,
                      color: Colors.white60,
                      size: 24,
                    ),
                    onPressed: _shuffle,
                  ),
                  GestureDetector(
                    key: const Key('playlist_detail_play_button'),
                    onTap: _playAll,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Track list + suggestions ─────────────────────────────────────
            Expanded(
              child: ListView(
                children: [
                  // ── Playlist tracks ────────────────────────────────────────
                  ...state.tracks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final track = entry.value;
                    return TrackTileInPlaylist(
                      key: Key('playlist_track_${track.id}'),
                      track: track,
                      onTap: () => _playFrom(index),
                    );
                  }),

                  // ── Suggestions section ────────────────────────────────────
                  // Show if: this is a playlist type AND
                  //   (a) suggestions are loading, OR
                  //   (b) suggestions are loaded and non-empty
                  if (playlist.type == PlaylistType.playlist &&
                      (state.isSuggestionsLoading ||
                          state.suggestions.isNotEmpty)) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Text(
                        'Suggestions for your new playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Loading skeleton while fetching
                    if (state.isSuggestionsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF5500),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      ...state.suggestions.map(
                        (suggestion) => TrackTileInPlaylist(
                          key: Key('suggestion_${suggestion.id}'),
                          track: suggestion,
                          onTap: () => _fetchAndPlay(suggestion),
                          trailingWidget: IconButton(
                            key: Key('add_suggestion_${suggestion.id}'),
                            icon: const Icon(
                              Icons.add_box_outlined,
                              color: Colors.white70,
                              size: 26,
                            ),
                            onPressed: () => ref
                                .read(playlistDetailProvider.notifier)
                                .addSuggestion(suggestion),
                          ),
                        ),
                      ),

                    // Refresh button — always visible once suggestions loaded
                    if (!state.isSuggestionsLoading)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('refresh_suggestions_button'),
                            onPressed: () => ref
                                .read(playlistDetailProvider.notifier)
                                .refreshSuggestions(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Refresh suggestions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}