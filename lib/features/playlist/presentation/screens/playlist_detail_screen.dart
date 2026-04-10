// lib/features/playlist/presentation/screens/playlist_detail_screen.dart
/// Detail screen for a playlist, album, or station — all three share this screen.
/// [PlaylistEntity.type] controls what the header shows and which actions are available.
/// Player wiring uses [PlaylistMockData.getSourceTracksFor] to get full [Track] entities
/// since [PlaylistDetailState] only holds lightweight [PlaylistTrack] rows.
/// Reached via GoRouter from any module using the /library/playlists/:id route pattern.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/mock/playlist_mock_data.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.isOwner = false,
  });

  final String playlistId;
  final bool isOwner;

  // ── Player helpers ─────────────────────────────────────────────────────────

  List<Track> _sourceTracks() =>
      PlaylistMockData.instance.getSourceTracksFor(playlistId);

  void _playAll(WidgetRef ref) {
    final tracks = _sourceTracks();
    if (tracks.isEmpty) return;
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(
          tracks,
          initialIndex: 0, // ← was startIndex
        );
  }

  void _shuffle(WidgetRef ref) {
    final tracks = List<Track>.from(_sourceTracks())..shuffle();
    if (tracks.isEmpty) return;
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(
          tracks,
          initialIndex: 0, // ← was startIndex
        );
  }

  void _playFrom(WidgetRef ref, int index) {
    final tracks = _sourceTracks();
    if (tracks.isEmpty || index >= tracks.length) return;
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(
          tracks,
          initialIndex: index, // ← was startIndex
        );
  }
  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep mock store seeded whenever allTracksProvider updates
    ref.watch(playlistMockSeederProvider);

    final state = ref.watch(playlistDetailProvider(playlistId));

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
            // ── Header ───────────────────────────────────────────────────────
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
                      playlist.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: playlist.isLiked
                          ? const Color(0xFFFF5500)
                          : Colors.white,
                      size: 24,
                    ),
                    onPressed: () {},
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
                          playlistId: playlistId,
                          isOwner: isOwner,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  // Shuffle
                  IconButton(
                    key: const Key('playlist_detail_shuffle_button'),
                    icon: const Icon(
                      Icons.shuffle,
                      color: Colors.white60,
                      size: 24,
                    ),
                    onPressed: () => _shuffle(ref), // ← wired
                  ),
                  // Play all
                  GestureDetector(
                    key: const Key('playlist_detail_play_button'),
                    onTap: () => _playAll(ref), // ← wired
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

            // ── Track list + suggestions ──────────────────────────────────────
            Expanded(
              child: ListView(
                children: [
                  // Existing tracks
                  ...state.tracks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final track = entry.value;
                    return TrackTileInPlaylist(
                      key: Key('playlist_track_${track.id}'),
                      track: track,
                      onTap: () => _playFrom(ref, index), // ← wired
                    );
                  }),

                  // Suggestions section
                  if (state.showSuggestions) ...[
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
                    ...state.suggestions.map(
                      (suggestion) => TrackTileInPlaylist(
                        key: Key('suggestion_${suggestion.id}'),
                        track: suggestion,
                        onTap: () {}, // suggestions aren't in the queue yet
                        trailingWidget: IconButton(
                          key: Key('add_suggestion_${suggestion.id}'),
                          icon: const Icon(
                            Icons.add_box_outlined,
                            color: Colors.white70,
                            size: 26,
                          ),
                          onPressed: () {
                            ref
                                .read(
                                  playlistDetailProvider(playlistId).notifier,
                                )
                                .addSuggestion(suggestion);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          key: const Key('refresh_suggestions_button'),
                          onPressed: () => ref
                              .read(playlistDetailProvider(playlistId).notifier)
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

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
