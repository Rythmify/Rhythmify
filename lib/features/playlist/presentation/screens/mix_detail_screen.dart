// lib/features/playlist/presentation/screens/mix_detail_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/track.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/presentation/providers/home_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/local/local_saved_store.dart';
import '../providers/saved_content_provider.dart';
import '../widgets/playlist_shared_widgets.dart';

enum MixType { genre, daily, weekly }

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
    final asyncTracks = ref.watch(mixTracksProvider(mixId));

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
            'Could not load mix',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
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

class _MixDetailBody extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<_MixDetailBody> createState() => _MixDetailBodyState();
}

class _MixDetailBodyState extends ConsumerState<_MixDetailBody> {
  // FIX: derive _isSaved from savedMixesProvider instead of LocalSavedStore.
  // This keeps the heart in sync when the user likes/unlikes from this screen
  // or from any other screen in the same session.
  bool get _isSaved {
    final mixes = ref.watch(savedMixesProvider).asData?.value ?? [];
    return mixes.any((m) => m.mixId == widget.mixId);
  }

  Future<void> _toggleLike() async {
    final mix = SavedMix(
      mixId: widget.mixId,
      title: widget.mixTitle,
      ownerName: widget.ownerName,
      coverUrl: widget.coverUrl,
      trackCount: widget.tracks.length,
      savedAt: DateTime.now(),
    );
    // toggle() handles backend call + LocalSavedStore + playlistListProvider reload
    await ref.read(savedMixesProvider.notifier).toggle(mix);
  }

  Future<void> _play(List<Track> list, int index) async {
    if (list.isEmpty || index >= list.length) return;
    try {
      await ref
          .read(playerStateProvider.notifier)
          .loadAndPlayQueue(list, initialIndex: index);
    } catch (e) {
      debugPrint('[MixDetail] play failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch savedMixesProvider so the heart rebuilds reactively
    ref.watch(savedMixesProvider);

    final tracks = widget.tracks;
    final totalDuration = tracks.fold(Duration.zero, (s, t) => s + t.duration);
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes % 60;
    final s = totalDuration.inSeconds % 60;
    final durStr = h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

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
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppTheme.textPrimary,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  _Cover(url: widget.coverUrl, label: widget.mixTitle),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mixTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Private · $durStr · ${tracks.length} tracks',
                          style: AppTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('Made for ', style: AppTheme.labelSmall),
                            Flexible(
                              child: Text(
                                widget.ownerName,
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
                  IconButton(
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
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    onPressed: () => _showOptions(context),
                  ),
                  const Spacer(),
                  IconButton(
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
                        'No tracks in this mix yet',
                        style: AppTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 140),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        return TrackTileFromTrack(
                          key: Key('mix_track_${t.id}'),
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
                  _Cover(
                    url: widget.coverUrl,
                    label: widget.mixTitle,
                    size: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.mixTitle, style: AppTheme.bodyNormal),
                        Text(
                          'Made for ${widget.ownerName}',
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
            OptionSheetTile(
              icon: _isSaved ? Icons.favorite : Icons.favorite_border,
              label: _isSaved ? 'Remove from library' : 'Save to library',
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
        label.isNotEmpty ? label[0].toUpperCase() : 'M',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
