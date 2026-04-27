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
      final fullTrack =
          await ref.read(getTrackDetailsUseCaseProvider).call(pt.id);
      final state = ref.read(playlistDetailProvider);
      await ref.read(queueStateProvider.notifier).playQueue(
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
        allTracks
            .add(await ref.read(getTrackDetailsUseCaseProvider).call(pt.id));
      }
      await ref.read(queueStateProvider.notifier).playQueue(
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
        allTracks
            .add(await ref.read(getTrackDetailsUseCaseProvider).call(pt.id));
      }
      final shuffledTracks = List<Track>.from(allTracks)..shuffle();
      await ref.read(queueStateProvider.notifier).playQueue(
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

  /// Shows copy sheet pre-filled with "Copy of <name>".
  /// On create, opens the new owned playlist with full edit UI.
  void _showCopySheet(BuildContext context, PlaylistEntity playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CopyPlaylistSheet(
        sourcePlaylistId: playlist.id,
        defaultName: 'Copy of ${playlist.name}',
        isPublic: playlist.isPublic,
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

    // KEY FIX: suggestions are ONLY shown when ALL of these are true:
    // 1. widget.isOwner=true (passed from router — true only for owned playlists)
    // 2. playlist is not a track radio or generated mix (double-safety guard)
    // 3. playlist type is regular playlist (not album/station)
    // 4. not already requested this session
    final canShowSuggestions = widget.isOwner &&
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

    final coverUrl = playlist.coverUrl ??
        (state.tracks.isNotEmpty ? state.tracks.first.coverUrl : null);

    final showSuggestionsSection = widget.isOwner &&
        !playlist.isTrackRadio &&
        !playlist.isGeneratedMix &&
        playlist.type == PlaylistType.playlist &&
        (state.isSuggestionsLoading || state.suggestions.isNotEmpty);

    // Duration display
    final totalDuration = state.totalDuration;
    final durationText = _formatDuration(totalDuration);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('playlist_detail_back_button'),
                    icon: const Icon(Icons.chevron_left,
                        color: AppTheme.textPrimary, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  _CoverImage(
                      coverUrl: coverUrl, name: playlist.name, size: 56),
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
                        // Track count + duration
                        Text(
                          _buildSubtitle(playlist, state.tracks.length,
                              durationText),
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

            // ── Action bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
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
                    icon: const Icon(Icons.more_horiz,
                        color: AppTheme.textPrimary, size: 24),
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
                  // Copy button — visible for non-owned (mixes, radios, liked)
                  if (!widget.isOwner)
                    IconButton(
                      key: const Key('playlist_detail_copy_button'),
                      icon: const Icon(Icons.copy_all,
                          color: AppTheme.textSecondary, size: 22),
                      onPressed: () => _showCopySheet(context, playlist),
                      tooltip: 'Copy to my playlists',
                    ),
                  const Spacer(),
                  IconButton(
                    key: const Key('playlist_detail_shuffle_button'),
                    icon: const Icon(Icons.shuffle,
                        color: AppTheme.textSecondary, size: 24),
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
                      child: const Icon(Icons.play_arrow,
                          color: AppTheme.textPrimary, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.lighterSurface, height: 1),

            // ── Track list + suggestions ───────────────────────────────────
            Expanded(
              child: ListView(
                children: [
                  if (state.tracks.isEmpty && !showSuggestionsSection)
                    _emptyTracksState(playlist)
                  else
                    ...state.tracks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final track = entry.value;
                      return TrackTileInPlaylist(
                        key: Key('playlist_track_${track.id}'),
                        track: track,
                        onTap: () => _playFrom(index),
                      );
                    }),

                  // Suggestions — ONLY owned regular playlists, never radios/mixes
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
                        (suggestion) => TrackTileInPlaylist(
                          key: Key('suggestion_${suggestion.id}'),
                          track: suggestion,
                          onTap: () => _fetchAndPlay(suggestion),
                          trailingWidget: IconButton(
                            key: Key('add_suggestion_${suggestion.id}'),
                            icon: const Icon(Icons.add_box_outlined,
                                color: AppTheme.textSecondary, size: 26),
                            onPressed: () => ref
                                .read(playlistDetailProvider.notifier)
                                .addSuggestion(suggestion),
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
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Text('Refresh suggestions',
                                style: AppTheme.bodyNormal),
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

  String _buildSubtitle(
      PlaylistEntity playlist, int trackCount, String duration) {
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

  String _formatDuration(Duration d) {
    if (d.inSeconds == 0) return '';
    if (d.inHours > 0) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Widget _emptyTracksState(PlaylistEntity playlist) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.queue_music, color: AppTheme.textSecondary, size: 48),
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

// ── Copy playlist sheet ───────────────────────────────────────────────────────
// Shows CreatePlaylistSheet UI pre-filled with "Copy of <name>".
// On create, copies all tracks from the source into the new playlist.
class _CopyPlaylistSheet extends ConsumerStatefulWidget {
  const _CopyPlaylistSheet({
    required this.sourcePlaylistId,
    required this.defaultName,
    required this.isPublic,
    required this.onCreated,
  });

  final String sourcePlaylistId;
  final String defaultName;
  final bool isPublic;
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
    _isPublic = widget.isPublic;
    _nameController = TextEditingController(text: widget.defaultName);
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

    // Create the new playlist with the given name
    final created = await ref
        .read(playlistListProvider.notifier)
        .createPlaylist(name: name, isPublic: _isPublic);

    if (!mounted) return;

    if (created == null) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create playlist. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Copy tracks from source into new playlist
    final newId = await ref
        .read(playlistListProvider.notifier)
        .copyPlaylist(widget.sourcePlaylistId);

    if (!mounted) return;
    setState(() => _isCreating = false);
    Navigator.of(context).pop();

    // Navigate to the newly created owned playlist
    widget.onCreated(newId ?? created.id);
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
                onChanged:
                    _isCreating ? null : (v) => setState(() => _isPublic = v),
                activeThumbColor: const Color(0xFFFF5500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed:
                  _nameController.text.trim().isEmpty || _isCreating
                      ? null
                      : _onCreate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create playlist',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed:
                _isCreating ? null : () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ── Cover image widget ────────────────────────────────────────────────────────
class _CoverImage extends StatelessWidget {
  const _CoverImage(
      {required this.coverUrl, required this.name, required this.size});

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
                errorBuilder: (context, error, stackTrace) => _placeholder(),
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