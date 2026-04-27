// lib/features/playlist/presentation/screens/related_tracks_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/presentation/providers/home_providers.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';
import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';
import '../providers/saved_content_provider.dart';
import '../widgets/playlist_shared_widgets.dart';

enum RelatedTracksSource { track, station }

final _stationTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>((ref, artistId) async {
      final ds = ref.read(playlistDatasourceProvider);
      final pts = await ds.fetchStationTracks(artistId, limit: 50);
      return pts.map(_toTrack).toList();
    });

Track _toTrack(PlaylistTrack pt) => Track(
  id: pt.id,
  userId: '',
  title: pt.title,
  artist: pt.artistName,
  audioUrl: pt.id,
  coverImage: pt.coverUrl,
  duration: pt.duration,
  playCount: pt.playCount,
  createdAt: DateTime.now(),
);

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
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text(
            'Could not load tracks',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
      data: (tracks) => _Body(
        sourceId: sourceId,
        source: source,
        title: title,
        basedOnName: basedOnName,
        coverUrl: coverUrl,
        tracks: tracks,
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({
    required this.sourceId,
    required this.source,
    required this.title,
    required this.basedOnName,
    required this.tracks,
    this.coverUrl,
  });

  final String sourceId;
  final RelatedTracksSource source;
  final String title;
  final String basedOnName;
  final String? coverUrl;
  final List<Track> tracks;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  // ── Station: read isSaved from provider (not LocalSavedStore) ─────────────
  // FIX: LocalSavedStore.isStationSaved() was always false because
  // SavedStationsNotifier no longer writes to LocalSavedStore — it calls the
  // backend then refreshes from it. Reading the provider is always correct.
  bool get _isStationSaved {
    final stations = ref.watch(savedStationsProvider).asData?.value ?? [];
    return stations.any((s) => s.artistId == widget.sourceId);
  }

  // ── Track radio: read isSaved from provider ────────────────────────────────
  bool get _isTrackRadioSaved {
    return ref
            .watch(savedTrackRadiosProvider)
            .asData
            ?.value
            .contains(widget.sourceId) ??
        false;
  }

  bool get _isSaved {
    if (widget.source == RelatedTracksSource.station) return _isStationSaved;
    return _isTrackRadioSaved;
  }

  Future<void> _toggleLike() async {
    if (widget.source == RelatedTracksSource.station) {
      final station = SavedStation(
        artistId: widget.sourceId,
        artistName: widget.basedOnName,
        stationName: widget.title,
        coverUrl: widget.coverUrl,
        trackCount: widget.tracks.length,
        savedAt: DateTime.now(),
      );
      await ref.read(savedStationsProvider.notifier).toggle(station);
    } else {
      // Track radio — POST /tracks/:id/like-radio
      await ref.read(savedTrackRadiosProvider.notifier).toggle(widget.sourceId);
    }
  }

  Future<void> _play(List<Track> list, int index) async {
    if (list.isEmpty || index >= list.length) return;
    try {
      await ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: list,
            initialIndex: index,
            context: QueueContext(
              type: QueueSource.station,
              sourceId: widget.sourceId,
            ),
          );
    } catch (e) {
      debugPrint('[RelatedTracks] play failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers so heart rebuilds reactively
    ref.watch(savedStationsProvider);
    ref.watch(savedTrackRadiosProvider);

    final tracks = widget.tracks;
    final totalDuration = tracks.fold(Duration.zero, (s, t) => s + t.duration);
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final durStr = h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    final isStation = widget.source == RelatedTracksSource.station;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('related_tracks_back_button'),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppTheme.textPrimary,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  _Cover(url: widget.coverUrl, label: widget.title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (isStation) ...[
                              const Icon(
                                Icons.sensors,
                                size: 13,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Artist Station · $durStr · ${tracks.length} tracks',
                                  style: AppTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else
                              Flexible(
                                child: Text(
                                  'Related Tracks · $durStr · ${tracks.length} tracks',
                                  style: AppTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('Based on ', style: AppTheme.labelSmall),
                            Flexible(
                              child: Text(
                                widget.basedOnName,
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

            // ── Action bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  // Heart is now active for BOTH station and track radio
                  IconButton(
                    key: const Key('related_tracks_like_button'),
                    icon: Icon(
                      _isSaved ? Icons.favorite : Icons.favorite_border,
                      color: _isSaved
                          ? AppTheme.primaryBrand
                          : AppTheme.textPrimary,
                      size: 24,
                    ),
                    onPressed: _toggleLike,
                  ),
                  IconButton(
                    key: const Key('related_tracks_more_button'),
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    onPressed: () => _showOptions(context),
                  ),
                  const Spacer(),
                  IconButton(
                    key: const Key('related_tracks_shuffle_button'),
                    icon: const Icon(
                      Icons.shuffle,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    onPressed: () {
                      final shuffled = List<Track>.from(tracks)..shuffle();
                      _play(shuffled, 0);
                    },
                  ),
                  GestureDetector(
                    key: const Key('related_tracks_play_button'),
                    onTap: () => _play(tracks, 0),
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

            // ── Track list ──────────────────────────────────────────────
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text(
                        'No tracks found',
                        style: AppTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 140),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        return TrackTileFromTrack(
                          key: Key('related_${t.id}_$index'),
                          track: t,
                          onTap: () => _play(tracks, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final isStation = widget.source == RelatedTracksSource.station;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
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
                  _Cover(url: widget.coverUrl, label: widget.title, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTheme.bodyNormal),
                        Text(
                          'Based on ${widget.basedOnName}',
                          style: AppTheme.artistTitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.lighterSurface, height: 1),
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
            // Save option for both station and track radio
            OptionSheetTile(
              icon: _isSaved
                  ? (isStation ? Icons.sensors_off : Icons.favorite)
                  : (isStation ? Icons.sensors : Icons.favorite_border),
              label: _isSaved
                  ? (isStation
                        ? 'Remove from Saved Stations'
                        : 'Remove from library')
                  : (isStation ? 'Save Station' : 'Save to library'),
              onTap: () {
                Navigator.of(context).pop();
                _toggleLike();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

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
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.surface,
    child: Center(
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : 'S',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
