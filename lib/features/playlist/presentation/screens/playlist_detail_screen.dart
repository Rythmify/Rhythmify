// lib/features/playlist/presentation/screens/playlist_detail_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';
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
  bool _suggestionsRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistDetailProvider.notifier).init(widget.playlistId);
    });
  }

  Future<void> _fetchAndPlay(PlaylistTrack pt) async {
    try {
      final fullTrack = await ref
          .read(getTrackDetailsUseCaseProvider)
          .call(pt.id);
      final state = ref.read(playlistDetailProvider);
      await ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: [fullTrack],
            initialIndex: 0,
            context: QueueContext(
              type: _mapPlaylistTypeToQueueSource(state.playlist?.type),
              sourceId: widget.playlistId,
            ),
          );
    } catch (e) {
      debugPrint('[PlaylistDetail] Failed to fetch/play "${pt.title}": $e');
    }
  }

  Future<void> _playFrom(int index) async {
    final state = ref.read(playlistDetailProvider);
    final tracks = state.tracks;
    if (tracks.isEmpty || index >= tracks.length) return;
    try {
      final List<Track> allTracks = [];
      for (final pt in tracks) {
        allTracks.add(
          await ref.read(getTrackDetailsUseCaseProvider).call(pt.id),
        );
      }
      await ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: allTracks,
            initialIndex: index,
            context: QueueContext(
              type: _mapPlaylistTypeToQueueSource(state.playlist?.type),
              sourceId: widget.playlistId,
            ),
          );
    } catch (e) {
      debugPrint('[PlaylistDetail] Failed to play: $e');
    }
  }

  QueueSource _mapPlaylistTypeToQueueSource(PlaylistType? type) {
    switch (type) {
      case PlaylistType.playlist:
        return QueueSource.playlist;
      case PlaylistType.album:
        return QueueSource.album;
      case PlaylistType.station:
        return QueueSource.station;
      default:
        return QueueSource.playlist;
    }
  }

  Future<void> _playAll() async {
    final tracks = ref.read(playlistDetailProvider).tracks;
    if (tracks.isEmpty) return;
    await _playFrom(0);
  }

  Future<void> _shuffle() async {
    final state = ref.read(playlistDetailProvider);
    final tracks = state.tracks;
    if (tracks.isEmpty) return;
    try {
      final List<Track> allTracks = [];
      for (final pt in tracks) {
        allTracks.add(
          await ref.read(getTrackDetailsUseCaseProvider).call(pt.id),
        );
      }
      final shuffledTracks = List<Track>.from(allTracks)..shuffle();
      await ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: shuffledTracks,
            initialIndex: 0,
            context: QueueContext(
              type: _mapPlaylistTypeToQueueSource(state.playlist?.type),
              sourceId: widget.playlistId,
            ),
          );
    } catch (e) {
      debugPrint('[PlaylistDetail] shuffle failed: $e');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds == 0) return '';
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  String _buildSubtitle(
    PlaylistEntity playlist,
    int trackCount,
    String duration,
  ) {
    final label = playlist.isGeneratedMix
        ? 'Mix'
        : playlist.isTrackRadio
        ? 'Radio'
        : playlist.typeLabel;
    final tracks = trackCount == 1 ? '1 track' : '$trackCount tracks';
    if (duration.isNotEmpty && trackCount > 0) {
      return '$label · $tracks · $duration';
    }
    return '$label · $tracks';
  }

  void _showCopySheet(BuildContext context, PlaylistEntity playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CopyPlaylistSheet(
        sourceEntity: playlist,
        onCreated: (newId) {
          context.push('/library/playlists/$newId', extra: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistDetailProvider);
    final playlist = state.playlist;

    // Suggestions only for owned regular playlists — never radios or mixes
    final canShowSuggestions =
        widget.isOwner &&
        !state.isLoading &&
        playlist != null &&
        !playlist.isTrackRadio &&
        !playlist.isGeneratedMix &&
        playlist.type == PlaylistType.playlist &&
        !_suggestionsRequested;

    if (canShowSuggestions) {
      _suggestionsRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(playlistDetailProvider.notifier).loadSuggestionsIfOwner();
      });
    }

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
      );
    }

    if (playlist == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text('Playlist not found', style: AppTheme.bodyMedium),
        ),
      );
    }

    final coverUrl =
        playlist.coverUrl ??
        (state.tracks.isNotEmpty ? state.tracks.first.coverUrl : null);

    final showSuggestionsSection =
        widget.isOwner &&
        !playlist.isTrackRadio &&
        !playlist.isGeneratedMix &&
        playlist.type == PlaylistType.playlist &&
        (state.isSuggestionsLoading || state.suggestions.isNotEmpty);

    final durationText = _formatDuration(state.totalDuration);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header (compact) ────────────────────────────────────
            _PlaylistHeader(
              playlist: playlist,
              coverUrl: coverUrl,
              trackCount: state.tracks.length,
              subtitle: _buildSubtitle(
                playlist,
                state.tracks.length,
                durationText,
              ),
              isOwner: widget.isOwner,
              onBack: () => context.pop(),
              onLike: () =>
                  ref.read(playlistDetailProvider.notifier).toggleLike(),
              onMore: () => showModalBottomSheet(
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
                  // Pop detail screen after delete
                  onDeleted: () => context.pop(),
                ),
              ),
              onCopy: !widget.isOwner
                  ? () => _showCopySheet(context, playlist)
                  : null,
              onShuffle: _shuffle,
              onPlay: _playAll,
              formatCount: _formatCount,
            ),

            const Divider(color: AppTheme.lighterSurface, height: 1),

            // ── Scrollable track list — takes remaining 2/3+ of screen ────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (state.tracks.isEmpty && !showSuggestionsSection)
                    _emptyTracksState(playlist)
                  else
                    ...state.tracks.asMap().entries.map((entry) {
                      return TrackTileInPlaylist(
                        key: Key('playlist_track_${entry.value.id}'),
                        track: entry.value,
                        onTap: () => _playFrom(entry.key),
                      );
                    }),

                  // Suggestions — ONLY owned regular playlists
                  if (showSuggestionsSection) ...[
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
                        (s) => TrackTileInPlaylist(
                          key: Key('suggestion_${s.id}'),
                          track: s,
                          onTap: () => _fetchAndPlay(s),
                          trailingWidget: IconButton(
                            key: Key('add_suggestion_${s.id}'),
                            icon: const Icon(
                              Icons.add_box_outlined,
                              color: AppTheme.textSecondary,
                              size: 26,
                            ),
                            onPressed: () => ref
                                .read(playlistDetailProvider.notifier)
                                .addSuggestion(s),
                          ),
                        ),
                      ),
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

                  // Bottom padding for player bar
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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.queue_music,
            color: AppTheme.textSecondary,
            size: 48,
          ),
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
    );
  }
}

// ── Compact fixed header extracted to its own widget ─────────────────────────
// Keeps the detail screen's Column clean and prevents overflow.
class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.playlist,
    required this.coverUrl,
    required this.trackCount,
    required this.subtitle,
    required this.isOwner,
    required this.onBack,
    required this.onLike,
    required this.onMore,
    required this.onShuffle,
    required this.onPlay,
    required this.formatCount,
    this.onCopy,
  });

  final PlaylistEntity playlist;
  final String? coverUrl;
  final int trackCount;
  final String subtitle;
  final bool isOwner;
  final VoidCallback onBack;
  final VoidCallback onLike;
  final VoidCallback onMore;
  final VoidCallback? onCopy;
  final VoidCallback onShuffle;
  final VoidCallback onPlay;
  final String Function(int) formatCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Title row ────────────────────────────────────────────────────
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
                onPressed: onBack,
              ),
              _CoverImage(coverUrl: coverUrl, name: playlist.name, size: 52),
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
                    Text(subtitle, style: AppTheme.labelSmall),
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
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Row(
            children: [
              // Like button
              GestureDetector(
                key: const Key('playlist_detail_like_button'),
                onTap: onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      playlist.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: playlist.isLiked
                          ? AppTheme.primaryBrand
                          : AppTheme.textPrimary,
                      size: 24,
                    ),
                    if (playlist.likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        formatCount(playlist.likeCount),
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
              // More button
              IconButton(
                key: const Key('playlist_detail_more_button'),
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
                onPressed: onMore,
              ),
              // Copy button (non-owned only)
              if (onCopy != null)
                IconButton(
                  key: const Key('playlist_detail_copy_button'),
                  icon: const Icon(
                    Icons.copy_all,
                    color: AppTheme.textSecondary,
                    size: 22,
                  ),
                  onPressed: onCopy,
                  tooltip: 'Copy to my playlists',
                ),
              const Spacer(),
              // Shuffle
              IconButton(
                key: const Key('playlist_detail_shuffle_button'),
                icon: const Icon(
                  Icons.shuffle,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
                onPressed: onShuffle,
              ),
              // Play
              GestureDetector(
                key: const Key('playlist_detail_play_button'),
                onTap: onPlay,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppTheme.lighterSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppTheme.textPrimary,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Copy playlist sheet ───────────────────────────────────────────────────────
class _CopyPlaylistSheet extends ConsumerStatefulWidget {
  const _CopyPlaylistSheet({
    required this.sourceEntity,
    required this.onCreated,
  });

  final PlaylistEntity sourceEntity;
  final void Function(String newPlaylistId) onCreated;

  @override
  ConsumerState<_CopyPlaylistSheet> createState() => _CopyPlaylistSheetState();
}

class _CopyPlaylistSheetState extends ConsumerState<_CopyPlaylistSheet> {
  late final TextEditingController _nameController;
  late bool _isPublic;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.sourceEntity.isPublic;
    _nameController = TextEditingController(
      text: 'Copy of ${widget.sourceEntity.name}',
    );
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.text.length,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isCreating) return;
    setState(() => _isCreating = true);

    final newId = await ref
        .read(playlistListProvider.notifier)
        .copyPlaylist(
          widget.sourceEntity.id,
          overrideName: name,
          overridePublic: _isPublic,
          sourceEntity: widget.sourceEntity,
        );

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (newId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create playlist. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    widget.onCreated(newId);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, keyboardHeight + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 100,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              counterStyle: TextStyle(color: Colors.grey[600]),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Make this playlist public',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              Switch(
                value: _isPublic,
                onChanged: _isCreating
                    ? null
                    : (v) => setState(() => _isPublic = v),
                activeThumbColor: const Color(0xFFFF5500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _nameController.text.trim().isEmpty || _isCreating
                  ? null
                  : _onCreate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create playlist',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cover image widget ────────────────────────────────────────────────────────
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
        child:
            coverUrl != null &&
                coverUrl!.isNotEmpty &&
                coverUrl!.startsWith('http')
            ? Image.network(
                coverUrl!,
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
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
