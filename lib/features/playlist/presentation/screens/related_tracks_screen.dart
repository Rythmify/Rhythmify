// lib/features/playlist/presentation/screens/related_tracks_screen.dart
//
// Shared screen for two entry points:
//   1. "More of what you like" → partner passes track.id
//      → calls GET /tracks/{id}/related?limit=50
//   2. "Discover with Stations" → partner passes artist_id
//      → calls GET /home/stations/{artist_id}/tracks
//
// UI: station-style — "Artist Station · duration · N tracks" / "Based on [name]"
// No suggestions, no edit, no delete.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_shared_widgets.dart';

// ── Source type ───────────────────────────────────────────────────────────────
enum RelatedTracksSource {
  track, // GET /tracks/{id}/related  — "more of what you like"
  station, // GET /home/stations/{artist_id}/tracks — "discover with stations"
}

// ── State ─────────────────────────────────────────────────────────────────────
class RelatedTracksState {
  const RelatedTracksState({
    this.tracks = const [],
    this.isLoading = true,
    this.error,
  });

  final List<PlaylistTrack> tracks;
  final bool isLoading;
  final String? error;

  RelatedTracksState copyWith({
    List<PlaylistTrack>? tracks,
    bool? isLoading,
    String? error,
  }) => RelatedTracksState(
    tracks: tracks ?? this.tracks,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class RelatedTracksNotifier extends Notifier<RelatedTracksState> {
  @override
  RelatedTracksState build() => const RelatedTracksState(isLoading: true);

  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  Future<void> load({
    required String sourceId,
    required RelatedTracksSource source,
  }) async {
    state = const RelatedTracksState(isLoading: true);
    print('[RelatedTracks] load() sourceId="$sourceId" source=$source');
    try {
      final List<PlaylistTrack> tracks;
      switch (source) {
        case RelatedTracksSource.track:
          tracks = await _ds.fetchRelatedTracks(sourceId, limit: 50);
        case RelatedTracksSource.station:
          tracks = await _ds.fetchStationTracks(sourceId, limit: 50);
      }
      print('[RelatedTracks] ✅ Got ${tracks.length} tracks');
      state = RelatedTracksState(tracks: tracks, isLoading: false);
    } catch (e) {
      print('[RelatedTracks] ❌ Failed: $e');
      state = RelatedTracksState(
        isLoading: false,
        error: 'Could not load tracks',
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final relatedTracksProvider =
    NotifierProvider<RelatedTracksNotifier, RelatedTracksState>(
      RelatedTracksNotifier.new,
    );

// ── Screen ────────────────────────────────────────────────────────────────────
class RelatedTracksScreen extends ConsumerStatefulWidget {
  const RelatedTracksScreen({
    super.key,
    required this.sourceId,
    required this.source,
    required this.basedOnName,
    required this.title,
    this.coverUrl,
  });

  final String sourceId;
  final RelatedTracksSource source;
  final String basedOnName; // shown as "Based on [basedOnName]"
  final String title; // shown as the header name
  final String? coverUrl;

  @override
  ConsumerState<RelatedTracksScreen> createState() =>
      _RelatedTracksScreenState();
}

class _RelatedTracksScreenState extends ConsumerState<RelatedTracksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(relatedTracksProvider.notifier)
          .load(sourceId: widget.sourceId, source: widget.source);
    });
  }

  Future<void> _fetchAndPlay(PlaylistTrack pt) async {
    try {
      final fullTrack = await ref
          .read(getTrackDetailsUseCaseProvider)
          .call(pt.id);
      await ref.read(playerStateProvider.notifier).loadAndPlayQueue([
        fullTrack,
      ], initialIndex: 0);
    } catch (e) {
      debugPrint('[RelatedTracks] Failed to play "${pt.title}": $e');
    }
  }

  Future<void> _playAll() async {
    final tracks = ref.read(relatedTracksProvider).tracks;
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _shuffle() async {
    final tracks = List<PlaylistTrack>.from(
      ref.read(relatedTracksProvider).tracks,
    )..shuffle();
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _playFrom(int index) async {
    final tracks = ref.read(relatedTracksProvider).tracks;
    if (tracks.isEmpty || index >= tracks.length) return;
    await _fetchAndPlay(tracks[index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(relatedTracksProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5500)),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Center(
          child: Text(
            state.error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final tracks = state.tracks;
    final totalDuration = tracks.fold(
      Duration.zero,
      (sum, t) => sum + t.duration,
    );
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final durationStr = h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

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
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child:
                          widget.coverUrl != null &&
                              widget.coverUrl!.isNotEmpty &&
                              widget.coverUrl!.startsWith('http')
                          ? Image.network(
                              widget.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _CoverPlaceholder(widget.title),
                            )
                          : _CoverPlaceholder(widget.title),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Artist Station · $durationStr · ${tracks.length} tracks',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Based on ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                widget.basedOnName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                  const IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => _showOptions(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.shuffle,
                      color: Colors.white60,
                      size: 24,
                    ),
                    onPressed: _shuffle,
                  ),
                  GestureDetector(
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

            // ── Track list ────────────────────────────────────────────────────
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text(
                        'No tracks found',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) => TrackTileInPlaylist(
                        key: Key('related_track_${tracks[index].id}'),
                        track: tracks[index],
                        onTap: () => _playFrom(index),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child:
                          widget.coverUrl != null && widget.coverUrl!.isNotEmpty
                          ? Image.network(widget.coverUrl!, fit: BoxFit.cover)
                          : _CoverPlaceholder(widget.title),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Based on ${widget.basedOnName}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            OptionSheetTile(
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              icon: Icons.add_to_queue,
              label: 'Play last',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Cover placeholder ─────────────────────────────────────────────────────────
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'S',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
