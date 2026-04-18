// lib/features/playlist/presentation/screens/mix_detail_screen.dart

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

// ── Mix type ──────────────────────────────────────────────────────────────────
enum MixType { genre, daily, weekly }

// ── State ─────────────────────────────────────────────────────────────────────
class MixDetailState {
  const MixDetailState({
    this.tracks = const [],
    this.isLoading = true,
    this.error,
  });

  final List<PlaylistTrack> tracks;
  final bool isLoading;
  final String? error;

  MixDetailState copyWith({
    List<PlaylistTrack>? tracks,
    bool? isLoading,
    String? error,
  }) => MixDetailState(
    tracks: tracks ?? this.tracks,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class MixDetailNotifier extends Notifier<MixDetailState> {
  @override
  MixDetailState build() => const MixDetailState(isLoading: true);

  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  Future<void> load({required String mixId, required MixType mixType}) async {
    state = const MixDetailState(isLoading: true);
    try {
      List<PlaylistTrack> tracks;
      switch (mixType) {
        case MixType.daily:
          tracks = await _ds.fetchDailyMixTracks();
        case MixType.weekly:
          tracks = await _ds.fetchWeeklyMixTracks();
        case MixType.genre:
          tracks = await _ds.fetchMixTracks(mixId);
      }
      state = MixDetailState(tracks: tracks, isLoading: false);
      print('[MixDetail] ✅ Loaded ${tracks.length} tracks');
    } catch (e) {
      print('[MixDetail] ❌ Failed: $e');
      state = MixDetailState(isLoading: false, error: 'Could not load mix');
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final mixDetailProvider = NotifierProvider<MixDetailNotifier, MixDetailState>(
  MixDetailNotifier.new,
);

// ── Screen ────────────────────────────────────────────────────────────────────
class MixDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MixDetailScreen> createState() => _MixDetailScreenState();
}

class _MixDetailScreenState extends ConsumerState<MixDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(mixDetailProvider.notifier)
          .load(mixId: widget.mixId, mixType: widget.mixType);
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
      debugPrint('[MixDetail] Failed to play "${pt.title}": $e');
    }
  }

  Future<void> _playAll() async {
    final tracks = ref.read(mixDetailProvider).tracks;
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _shuffle() async {
    final tracks = List<PlaylistTrack>.from(ref.read(mixDetailProvider).tracks)
      ..shuffle();
    if (tracks.isEmpty) return;
    await _fetchAndPlay(tracks.first);
  }

  Future<void> _playFrom(int index) async {
    final tracks = ref.read(mixDetailProvider).tracks;
    if (tracks.isEmpty || index >= tracks.length) return;
    await _fetchAndPlay(tracks[index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mixDetailProvider);

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
    final trackCount = widget.trackCount ?? tracks.length;
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
                      child: widget.coverUrl != null
                          ? Image.network(
                              widget.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _Placeholder(widget.mixTitle),
                            )
                          : _Placeholder(widget.mixTitle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mixTitle,
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
                          'Private · $durationStr · $trackCount tracks',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Made for ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                widget.ownerName,
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
                        'No tracks in this mix yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) => TrackTileInPlaylist(
                        key: Key('mix_track_${tracks[index].id}'),
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
                      child: widget.coverUrl != null
                          ? Image.network(widget.coverUrl!, fit: BoxFit.cover)
                          : _Placeholder(widget.mixTitle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mixTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Made for ${widget.ownerName}',
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
            OptionSheetTile(
              icon: Icons.copy_all,
              label: 'Copy mix',
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
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'M',
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
