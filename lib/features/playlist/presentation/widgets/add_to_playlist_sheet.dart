// lib/features/playlist/presentation/widgets/add_to_playlist_sheet.dart
/// This file contains the UI and logic for adding a track to one or more
/// playlists using a bottom sheet.
///
/// Features:
/// - Displays the user's playlists
/// - Supports playlist searching/filtering
/// - Allows selecting multiple playlists
/// - Allows creating a new playlist directly from the sheet
/// - Adds the selected track to all chosen playlists
/// - Shows loading and success/error feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'playlist_shared_widgets.dart';

/// Shows the "Add to playlist" picker bottom sheet.
Future<void> showAddToPlaylistSheet(
  BuildContext context, {
  required String trackId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => _AddToPlaylistSheet(trackId: trackId),
  );
}

class _AddToPlaylistSheet extends ConsumerStatefulWidget {
  const _AddToPlaylistSheet({required this.trackId});
  final String trackId;

  @override
  ConsumerState<_AddToPlaylistSheet> createState() =>
      _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<_AddToPlaylistSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _selectedIds = {};
  List<PlaylistEntity> _ownedPlaylists = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlaylists());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final ds = ref.read(playlistDatasourceProvider);
      final playlists = await ds.fetchMyPlaylists(filter: 'created');
      if (mounted) {
        setState(() {
          _ownedPlaylists = playlists
              .where(
                (p) =>
                    p.type == PlaylistType.playlist &&
                    !p.isGeneratedMix &&
                    !p.isTrackRadio,
              )
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[AddToPlaylistSheet] _loadPlaylists failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PlaylistEntity> get _filtered {
    if (_query.isEmpty) return _ownedPlaylists;
    return _ownedPlaylists
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Future<void> _createAndSelect(String name) async {
    try {
      final ds = ref.read(playlistDatasourceProvider);
      final newPlaylist = await ds.createPlaylist(
        name: name,
        isPublic: true,
        subtype: 'playlist',
      );
      if (mounted) {
        setState(() {
          _ownedPlaylists.insert(0, newPlaylist);
          _selectedIds.add(newPlaylist.id);
        });
      }
    } catch (e) {
      debugPrint('[AddToPlaylistSheet] createPlaylist failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create playlist. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    final controller = TextEditingController(text: 'Untitled playlist');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('add_to_playlist_create_dialog'),
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'New playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          key: const Key('add_to_playlist_new_name_field'),
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('add_to_playlist_cancel_create_button'),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            key: const Key('add_to_playlist_confirm_create_button'),
            onPressed: () {
              final name = controller.text.trim();
              Navigator.of(ctx).pop();
              if (name.isNotEmpty) _createAndSelect(name);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5500),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDone() async {
    if (_saving) return;
    if (_selectedIds.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);

    int successCount = 0;
    final ds = ref.read(playlistDatasourceProvider);

    for (final playlistId in _selectedIds) {
      try {
        await ds.addTrackToPlaylist(
          playlistId: playlistId,
          trackId: widget.trackId,
        );
        successCount++;
      } catch (e) {
        debugPrint('[AddToPlaylistSheet] addTrack to $playlistId failed: $e');
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successCount == 1
                ? 'Added to playlist'
                : 'Added to $successCount playlists',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final filtered = _filtered;

    return Container(
      key: const Key('add_to_playlist_sheet'),
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        children: [
          const BottomSheetHandle(),
          
          // Search row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      key: const Key('add_to_playlist_search_field'),
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search ${_ownedPlaylists.length} playlists',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.tune, color: Colors.grey[500], size: 22),
              ],
            ),
          ),

          // New playlist row
          InkWell(
            key: const Key('add_to_playlist_create_new_row'),
            onTap: _showCreateDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFF2A2A2A),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Playlist list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      key: Key('add_to_playlist_loading_indicator'),
                      color: AppTheme.primaryBrand,
                      strokeWidth: 2,
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty
                              ? 'No playlists yet.\nTap "New playlist" to create one.'
                              : 'No playlists match "$_query"',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        key: const Key('add_to_playlist_listview'),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final playlist = filtered[index];
                          final isSelected = _selectedIds.contains(playlist.id);
                          return _PlaylistPickerRow(
                            key: Key('playlist_item_${playlist.id}'),
                            playlist: playlist,
                            isSelected: isSelected,
                            onTap: () => setState(() {
                              isSelected
                                  ? _selectedIds.remove(playlist.id)
                                  : _selectedIds.add(playlist.id);
                            }),
                          );
                        },
                      ),
          ),

          // Fixed Done button
          Container(
            color: const Color(0xFF1C1C1C),
            padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 20),
            child: Center(
              child: SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  key: const Key('add_to_playlist_done_button'),
                  onPressed: _saving ? null : _onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            key: Key('add_to_playlist_saving_indicator'),
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistPickerRow extends StatelessWidget {
  const _PlaylistPickerRow({
    super.key,
    required this.playlist,
    required this.isSelected,
    required this.onTap,
  });

  final PlaylistEntity playlist;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = playlist.trackCount;
    final subtitle = count == 1 ? '1 track' : '$count tracks';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(playlist: playlist, size: 52, borderRadius: 0),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            // Animated checkbox
            AnimatedContainer(
              key: Key('playlist_checkbox_${playlist.id}'),
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF5500)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF5500) : Colors.white38,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}