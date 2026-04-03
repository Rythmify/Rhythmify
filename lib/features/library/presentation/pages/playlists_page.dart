import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Displays all playlists owned or saved by the authenticated user.
///
/// The "+" FAB opens a sheet to create a new playlist.
/// Long-pressing a playlist shows a delete option for owned playlists.
class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Playlists'), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        key: const Key('playlists_create_fab'),
        backgroundColor: AppTheme.primaryBrand,
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(playlistsProvider.notifier).load(),
        child: _buildBody(context, state, ref),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlaylistsState state, WidgetRef ref) {
    if (state.isLoading && state.playlists.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand));
    }

    if (state.error != null && state.playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: AppTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('playlists_retry_button'),
              onPressed: () => ref.read(playlistsProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.queue_music, color: AppTheme.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text('No playlists yet', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Create your first playlist.', style: AppTheme.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('playlists_empty_create_button'),
              onPressed: () => _showCreateSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Playlist'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrand, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('playlists_list_view'),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.playlists.length,
      itemBuilder: (context, index) => _PlaylistTile(playlist: state.playlists[index]),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CreatePlaylistSheet(ref: ref),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  final LibraryPlaylist playlist;

  const _PlaylistTile({required this.playlist});

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete playlist?', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${playlist.name}"? This cannot be undone.', style: AppTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTheme.labelLarge)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: AppTheme.labelLarge.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) ref.read(playlistsProvider.notifier).delete(playlist.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('playlist_item_${playlist.id}_list_tile'),
      onTap: () => context.push('/library/playlist'),
      onLongPress: playlist.isOwned ? () => _showDeleteDialog(context, ref) : null,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: playlist.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: playlist.coverUrl!,
                width: 52, height: 52, fit: BoxFit.cover,
                placeholder: (c, u) => Container(width: 52, height: 52, color: AppTheme.surface),
                errorWidget: (c, u, e) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        playlist.name,
        key: Key('playlist_item_${playlist.id}_name_text'),
        style: AppTheme.labelLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.trackCount} tracks • ${playlist.isPublic ? "Public" : "Private"}',
        key: Key('playlist_item_${playlist.id}_meta_text'),
        style: AppTheme.labelSmall,
      ),
      trailing: playlist.isOwned
          ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          : const Icon(Icons.bookmark, color: AppTheme.textSecondary, size: 18),
    );
  }

  Widget _placeholder() => Container(
    width: 52, height: 52, color: AppTheme.surface,
    child: const Icon(Icons.queue_music, color: AppTheme.textSecondary),
  );
}

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
    final state = widget.ref.watch(playlistsProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryBrand, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Public', style: AppTheme.labelLarge),
              const Spacer(),
              Switch(
                key: const Key('create_playlist_public_switch'),
                value: _isPublic,
                activeColor: AppTheme.primaryBrand,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('create_playlist_save_button'),
              onPressed: state.isSaving || _nameController.text.trim().isEmpty ? null : () async {
                final success = await widget.ref.read(playlistsProvider.notifier).create(
                  name: _nameController.text.trim(),
                  isPublic: _isPublic,
                );
                if (success && context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrand, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: state.isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
