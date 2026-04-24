// lib/features/playlist/presentation/screens/mix_detail_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/track.dart';
import '../../../feed/presentation/providers/home_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../widgets/playlist_shared_widgets.dart';

enum MixType { genre, daily, weekly }

// ── Screen ────────────────────────────────────────────────────────────────────
class MixDetailScreen extends ConsumerWidget {
  const MixDetailScreen({
    super.key,
    required this.mixId,
    required this.mixTitle,
    required this.ownerName,
    this.mixType = MixType.genre,
    this.coverUrl,
    this.trackCount,
  });

  final String mixId;
  final String mixTitle;
  final String ownerName;
  final MixType mixType;
  final String? coverUrl;
  final int? trackCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Sohaila's provider — already fetches & parses correctly
    final asyncTracks = ref.watch(mixTracksProvider(mixId));

    return asyncTracks.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5500))),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Center(
          child: Text('Could not load mix\n$e',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (tracks) => _MixDetailBody(
        mixId: mixId,
        mixTitle: mixTitle,
        ownerName: ownerName,
        coverUrl: coverUrl,
        tracks: tracks,
      ),
    );
  }
}

class _MixDetailBody extends ConsumerWidget {
  const _MixDetailBody({
    required this.mixId,
    required this.mixTitle,
    required this.ownerName,
    required this.tracks,
    this.coverUrl,
  });

  final String mixId;
  final String mixTitle;
  final String ownerName;
  final String? coverUrl;
  final List<Track> tracks;

  Future<void> _play(WidgetRef ref, int index) async {
    if (tracks.isEmpty || index >= tracks.length) return;
    try {
      await ref.read(playerStateProvider.notifier)
          .loadAndPlayQueue(tracks, initialIndex: index);
    } catch (e) {
      debugPrint('[MixDetail] play failed: $e');
    }
  }

  Future<void> _playAll(WidgetRef ref) => _play(ref, 0);

  Future<void> _shuffle(WidgetRef ref) async {
    if (tracks.isEmpty) return;
    final shuffled = List<Track>.from(tracks)..shuffle();
    try {
      await ref.read(playerStateProvider.notifier)
          .loadAndPlayQueue(shuffled, initialIndex: 0);
    } catch (e) {
      debugPrint('[MixDetail] shuffle failed: $e');
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  _Cover(url: coverUrl, label: mixTitle),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mixTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Private · $durStr · ${tracks.length} tracks',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(height: 2),
                        Row(children: [
                          Text('Made for ',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Flexible(
                            child: Text(ownerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  const IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white, size: 24),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                    onPressed: () => _showOptions(context, ref),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white60, size: 24),
                    onPressed: () => _shuffle(ref),
                  ),
                  GestureDetector(
                    onTap: () => _playAll(ref),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                          color: Color(0xFF3A3A3A), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Track list — uses Track directly, no second fetch
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text('No tracks in this mix yet',
                          style: TextStyle(color: Colors.grey[500])))
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        return TrackTileFromTrack(
                          key: Key('mix_track_${t.id}'),
                          track: t,
                          onTap: () => _play(ref, index),
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
                  _Cover(url: coverUrl, label: mixTitle, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mixTitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text('Made for $ownerName',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
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
            OptionSheetTile(
                icon: Icons.copy_all,
                label: 'Copy mix',
                onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
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
            label.isNotEmpty ? label[0].toUpperCase() : 'M',
            style: const TextStyle(
                color: Colors.white54, fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
      );
}