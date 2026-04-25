// lib/features/playlist/presentation/screens/playlist_detail_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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

  Future<void> _playFrom(int index) async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty || index >= tracks.length) return;
    try {
      final clickedTrack = await ref
          .read(getTrackDetailsUseCaseProvider)
          .call(tracks[index].id);
      await ref
          .read(playerStateProvider.notifier)
          .loadAndPlayQueue([clickedTrack], initialIndex: 0);
    } catch (e) {
      debugPrint('[PlaylistDetail] Failed to play: $e');
    }
  }

  Future<void> _playAll() async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty) return;
    await _playFrom(0);
  }

  Future<void> _shuffle() async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty) return;
    final shuffled = List.of(tracks)..shuffle();
    try {
      final clickedTrack = await ref
          .read(getTrackDetailsUseCaseProvider)
          .call(shuffled.first.id);
      await ref
          .read(playerStateProvider.notifier)
          .loadAndPlayQueue([clickedTrack], initialIndex: 0);
    } catch (e) {
      debugPrint('[PlaylistDetail] shuffle failed: $e');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistDetailProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
      );
    }

    if (state.playlist == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text('Playlist not found', style: AppTheme.bodyMedium),
        ),
      );
    }

    final playlist = state.playlist!;

    // ── Cover: prefer state.playlist.coverUrl, fall back to first track cover
    final coverUrl = playlist.coverUrl ??
        (state.tracks.isNotEmpty ? state.tracks.first.coverUrl : null);

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                      color: AppTheme.textPrimary,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  // Cover — uses resolved coverUrl with network fallback
                  _CoverImage(coverUrl: coverUrl, name: playlist.name, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodyNormal,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          playlist.detailSubtitle,
                          style: AppTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              playlist.type == PlaylistType.station
                                  ? 'Based on '
                                  : 'By ',
                              style: AppTheme.labelSmall,
                            ),
                            Flexible(
                              child: Text(
                                playlist.type == PlaylistType.station
                                    ? (playlist.seedArtistName ??
                                        playlist.ownerName)
                                    : playlist.ownerName.isNotEmpty
                                        ? playlist.ownerName
                                        : 'You',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
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
                  // Like button + count
                  GestureDetector(
                    key: const Key('playlist_detail_like_button'),
                    onTap: () =>
                        ref.read(playlistDetailProvider.notifier).toggleLike(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          playlist.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: playlist.isLiked
                              ? AppTheme.primaryBrand
                              : AppTheme.textPrimary,
                          size: 24,
                        ),
                        if (playlist.likeCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(playlist.likeCount),
                            style: AppTheme.labelSmall.copyWith(
                              color: playlist.isLiked
                                  ? AppTheme.primaryBrand
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: const Key('playlist_detail_more_button'),
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppTheme.textPrimary,
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
                      color: AppTheme.textSecondary,
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
                        color: AppTheme.lighterSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppTheme.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.lighterSurface, height: 1),

            // ── Track list + suggestions ─────────────────────────────────────
            Expanded(
              child: state.tracks.isEmpty && !state.isLoading
                  ? _emptyTracksState(playlist)
                  : ListView(
                      children: [
                        ...state.tracks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final track = entry.value;
                          return TrackTileInPlaylist(
                            key: Key('playlist_track_${track.id}'),
                            track: track,
                            onTap: () => _playFrom(index),
                          );
                        }),

                        // Suggestions — only for owned playlists
                        if (widget.isOwner &&
                            playlist.type == PlaylistType.playlist &&
                            (state.isSuggestionsLoading ||
                                state.suggestions.isNotEmpty)) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            child: Text(
                              'Suggestions for your new playlist',
                              style: AppTheme.titleLarge,
                            ),
                          ),
                          if (state.isSuggestionsLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBrand,
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
                                    color: AppTheme.textSecondary,
                                    size: 26,
                                  ),
                                  onPressed: () => ref
                                      .read(playlistDetailProvider.notifier)
                                      .addSuggestion(suggestion),
                                ),
                              ),
                            ),
                          if (!state.isSuggestionsLoading)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  key: const Key('refresh_suggestions_button'),
                                  onPressed: () => ref
                                      .read(playlistDetailProvider.notifier)
                                      .refreshSuggestions(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    'Refresh suggestions',
                                    style: AppTheme.bodyNormal,
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

  Widget _emptyTracksState(PlaylistEntity playlist) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.queue_music,
                color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(
              widget.isOwner
                  ? 'This playlist is empty\nAdd tracks to get started'
                  : 'No tracks available',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cover image widget ────────────────────────────────────────────────────────
// Separate from PlaylistCoverImage so we can pass a resolved URL directly
// without needing the full PlaylistEntity (useful when cover comes from tracks).
class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.coverUrl,
    required this.name,
    required this.size,
  });

  final String? coverUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size,
        height: size,
        child: coverUrl != null &&
                coverUrl!.isNotEmpty &&
                coverUrl!.startsWith('http')
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.surface,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}