import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Playlists page matching SoundCloud's layout.
///
/// Structure:
/// - Search bar
/// - "Import" and "Create new" action buttons row
/// - [ListView] of playlist items (artwork + name + meta + options)
class PlaylistsPage extends ConsumerStatefulWidget {
  const PlaylistsPage({super.key});

  @override
  ConsumerState<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends ConsumerState<PlaylistsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistsProvider);
    final filtered = _query.isEmpty
        ? state.playlists
        : state.playlists
              .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Playlists'), centerTitle: false),
      body: state.isLoading && state.playlists.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrand),
            )
          : state.playlists.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // ── Search bar ──────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: TextField(
                          key: const Key('playlists_search_text_field'),
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search ${state.playlists.length} playlists',
                            hintStyle: AppTheme.bodyMedium,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Import + Create row ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            key: const Key('playlists_import_button'),
                            onPressed: () {},
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('Import'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textPrimary,
                              side: const BorderSide(color: AppTheme.textSecondary),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            key: const Key('playlists_create_button'),
                            onPressed: () => _showCreateSheet(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create new'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textPrimary,
                              side: const BorderSide(color: AppTheme.textSecondary),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Playlist list ──────────────────────────────────────────
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    color: AppTheme.textSecondary,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No matching playlists',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search.',
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              key: const Key('playlists_list_view'),
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  _PlaylistTile(playlist: filtered[index]),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.queue_music,
              color: AppTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'No playlists yet',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first playlist.',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('playlists_empty_create_button'),
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create playlist'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.textSecondary),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CreatePlaylistSheet(ref: ref),
    );
  }
}

// ── Playlist tile ──────────────────────────────────────────────────────────────

class _PlaylistTile extends ConsumerWidget {
  final LibraryPlaylist playlist;

  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('playlist_item_${playlist.id}_list_tile'),
      onTap: () => context.push('/library/playlist'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: playlist.coverUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        playlist.name,
        key: Key('playlist_item_${playlist.id}_name_text'),
        style: AppTheme.labelLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.isOwned ? "" : "Saved · "}Playlist · ${playlist.trackCount} Tracks${playlist.isPublic ? "" : " 🔒"}',
        key: Key('playlist_item_${playlist.id}_meta_text'),
        style: AppTheme.labelSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        key: Key('playlist_item_${playlist.id}_more_icon_button'),
        icon: const Icon(
          Icons.more_vert,
          color: AppTheme.textSecondary,
          size: 20,
        ),
        onPressed: () => _showOptions(context, ref),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (playlist.isOwned)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete playlist',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      title: const Text(
                        'Delete playlist?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Delete "${playlist.name}"?',
                        style: AppTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: AppTheme.labelLarge),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(playlistsProvider.notifier).delete(playlist.id);
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 52,
    height: 52,
    color: AppTheme.lighterSurface,
    child: const Icon(Icons.queue_music, color: AppTheme.textSecondary),
  );
}

// ── Create playlist sheet ──────────────────────────────────────────────────────

class _CreatePlaylistSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreatePlaylistSheet({required this.ref});

  @override
  State<_CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<_CreatePlaylistSheet> {
  final _nameController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.ref.watch(playlistsProvider).isSaving;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('New Playlist', style: AppTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            key: const Key('create_playlist_name_text_field'),
            controller: _nameController,
            autofocus: true,
            style: AppTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: AppTheme.bodyMedium,
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBrand,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Public', style: AppTheme.labelLarge),
              const Spacer(),
              Switch(
                key: const Key('create_playlist_public_switch'),
                value: _isPublic,
                activeThumbColor: AppTheme.primaryBrand,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('create_playlist_save_button'),
              onPressed: isSaving || _nameController.text.trim().isEmpty
                  ? null
                  : () async {
                      final success = await widget.ref
                          .read(playlistsProvider.notifier)
                          .create(
                            name: _nameController.text.trim(),
                            isPublic: _isPublic,
                          );
                      if (success && context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Create'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
