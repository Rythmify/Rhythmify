// lib/features/playlist/presentation/screens/related_tracks_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/track.dart';
import '../../../feed/presentation/providers/home_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../widgets/playlist_shared_widgets.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';

// ── Source type ───────────────────────────────────────────────────────────────
enum RelatedTracksSource {
  track,   // GET /tracks/{id}/related  — "more of what you like"
  station, // GET /home/stations/{artist_id}/tracks
}

// ── Station tracks provider (wraps datasource, returns Track list) ────────────
final _stationTracksProvider =
    FutureProvider.autoDispose.family<List<Track>, String>((ref, artistId) async {
  final ds = ref.read(playlistDatasourceProvider);
  final playlistTracks = await ds.fetchStationTracks(artistId, limit: 50);
  return playlistTracks.map(_toTrack).toList();
});

Track _toTrack(PlaylistTrack pt) => Track(
      id: pt.id,
      userId: '',
      title: pt.title,
      artist: pt.artistName,
      audioUrl: pt.id, // player resolves via stream endpoint using id
      coverImage: pt.coverUrl,
      duration: pt.duration,
      playCount: pt.playCount,
      createdAt: DateTime.now(),
    );

// ── Screen ────────────────────────────────────────────────────────────────────
class RelatedTracksScreen extends ConsumerWidget {
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
  final String basedOnName;
  final String title;
  final String? coverUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTracks = source == RelatedTracksSource.track
        ? ref.watch(relatedTracksProvider(sourceId))
        : ref.watch(_stationTracksProvider(sourceId));

    return asyncTracks.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5500))),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Center(
          child: Text('Could not load tracks\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (tracks) => _Body(
        source: source,
        title: title,
        basedOnName: basedOnName,
        coverUrl: coverUrl,
        tracks: tracks,
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _Body extends ConsumerWidget {
  const _Body({
    required this.source,
    required this.title,
    required this.basedOnName,
    required this.tracks,
    this.coverUrl,
  });

  final RelatedTracksSource source;
  final String title;
  final String basedOnName;
  final String? coverUrl;
  final List<Track> tracks;

  Future<void> _play(WidgetRef ref, List<Track> list, int index) async {
    if (list.isEmpty || index >= list.length) return;
    try {
      await ref.read(playerStateProvider.notifier)
          .loadAndPlayQueue(list, initialIndex: index);
    } catch (e) {
      debugPrint('[RelatedTracks] play failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDuration = tracks.fold(Duration.zero, (s, t) => s + t.duration);
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final durStr = h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    // ── UI differs per source ─────────────────────────────────────────────────
    // Track (more of what you like): "Related Tracks · duration · N tracks" / "Based on [track title]"
    // Station:                        "Artist Station · (•) · duration · N tracks" / "Based on [artist]"
    final isStation = source == RelatedTracksSource.station;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  _Cover(url: coverUrl, label: title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),

                        // Subtitle row — station gets a radio icon
                        Row(
                          children: [
                            if (isStation) ...[
                              const Icon(Icons.sensors,
                                  size: 13, color: Colors.white54),
                              const SizedBox(width: 4),
                              Text(
                                'Artist Station · $durStr · ${tracks.length} tracks',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12),
                              ),
                            ] else
                              Text(
                                'Related Tracks · $durStr · ${tracks.length} tracks',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Attribution
                        Row(
                          children: [
                            Text(
                              'Based on ',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                            Flexible(
                              child: Text(
                                basedOnName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
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

            // ── Action bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  const IconButton(
                    icon: Icon(Icons.favorite_border,
                        color: Colors.white, size: 24),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white, size: 24),
                    onPressed: () => _showOptions(context, ref),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.shuffle,
                        color: Colors.white60, size: 24),
                    onPressed: () {
                      final shuffled = List<Track>.from(tracks)..shuffle();
                      _play(ref, shuffled, 0);
                    },
                  ),
                  GestureDetector(
                    onTap: () => _play(ref, tracks, 0),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                          color: Color(0xFF3A3A3A), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 28),
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
                      child: Text('No tracks found',
                          style: TextStyle(color: Colors.grey[500])))
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        return TrackTileFromTrack(
                          key: Key('related_${t.id}_$index'),
                          track: t,
                          onTap: () => _play(ref, tracks, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
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
            bottom: MediaQuery.of(context).padding.bottom + 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  _Cover(url: coverUrl, label: title, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text('Based on $basedOnName',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
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
                onTap: () => Navigator.of(context).pop()),
            OptionSheetTile(
                icon: Icons.add_to_queue,
                label: 'Play last',
                onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.label, this.size = 56});
  final String? url;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size,
        height: size,
        child: url != null && url!.isNotEmpty && url!.startsWith('http')
            ? Image.network(url!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF2A2A2A),
        child: Center(
          child: Text(
            label.isNotEmpty ? label[0].toUpperCase() : 'S',
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 22,
                fontWeight: FontWeight.w700),
          ),
        ),
      );
}