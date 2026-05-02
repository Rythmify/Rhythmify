// lib/features/playlist/presentation/widgets/edit_playlist_sheet.dart
/// This file contains the bottom sheet used for editing an existing playlist.
///
/// Features:
/// - Edit playlist name and description
/// - Change playlist visibility (public/private)
/// - Change playlist cover image
/// - Remove tracks from playlist
/// - Reorder playlist tracks
/// - Convert playlist between Playlist and Album
/// - Save playlist updates
///
/// Main Components:
/// - EditPlaylistSheet:
///     Main widget responsible for playlist editing.
///
/// - _onSave():
///     Saves playlist changes and updates playlist data.
///
/// - _openImagePicker():
///     Opens gallery picker for selecting a new cover image.
///
/// - _convert():
///     Converts playlist type between playlist and album.
///
/// - _EditTrackRow:
///     Displays editable playlist track rows.
///
/// - _ConvertTile:
///     Reusable conversion option tile.
///
/// Dependencies:
/// - Riverpod providers
/// - Image picker package
/// - Playlist entities/models
/// - Shared playlist UI widgets
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';
import 'playlist_shared_widgets.dart';

class EditPlaylistSheet extends ConsumerStatefulWidget {
  const EditPlaylistSheet({
    super.key,
    required this.playlistId,
    this.onConverted,
  });

  final String playlistId;
  final void Function(PlaylistType newType)? onConverted;

  @override
  ConsumerState<EditPlaylistSheet> createState() => _EditPlaylistSheetState();
}

class _EditPlaylistSheetState extends ConsumerState<EditPlaylistSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late bool _isPublic;
  late List<PlaylistTrack> _tracks;
  late PlaylistType _currentType;
  File? _pickedCoverFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(playlistDetailProvider);
    _nameController = TextEditingController(text: state.playlist?.name ?? '');
    _descController = TextEditingController(
      text: state.playlist?.description ?? '',
    );
    _isPublic = state.playlist?.isPublic ?? true;
    _tracks = List.from(state.tracks);
    _currentType = state.playlist?.type ?? PlaylistType.playlist;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _openImagePicker() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null && mounted) {
      setState(() => _pickedCoverFile = File(picked.path));
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final originalTracks = ref.read(playlistDetailProvider).tracks;
      for (final original in originalTracks) {
        if (!_tracks.any((t) => t.id == original.id)) {
          await ref
              .read(playlistDetailProvider.notifier)
              .removeTrack(original.id);
        }
      }

      await ref
          .read(playlistListProvider.notifier)
          .updatePlaylist(
            playlistId: widget.playlistId,
            name: name,
            isPublic: _isPublic,
            description: _descController.text.trim(),
          );

      if (_pickedCoverFile != null) {
        final ds = ref.read(playlistDatasourceProvider);
        await ds.updatePlaylist(
          playlistId: widget.playlistId,
          coverImage: _pickedCoverFile,
        );
        ref
            .read(playlistListProvider.notifier)
            .updateCoverImage(
              playlistId: widget.playlistId,
              localPath: _pickedCoverFile!.path,
            );
      }

      ref.read(playlistDetailProvider.notifier).reload();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('[EditSheet] ❌ save failed: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save changes. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _convert(
    BuildContext dialogContext,
    PlaylistType targetType,
  ) async {
    // 1. Close the confirm dialog
    Navigator.of(dialogContext).pop();
    // 2. Close the edit sheet immediately so it doesn't linger
    if (mounted) Navigator.of(context).pop();

    // Capture refs before any async gap
    final listNotifier = ref.read(playlistListProvider.notifier);
    final detailNotifier = ref.read(playlistDetailProvider.notifier);
    final onConverted = widget.onConverted;
    final playlistId = widget.playlistId;

    if (targetType == PlaylistType.album) {
      await listNotifier.convertToAlbum(playlistId);
    } else {
      await listNotifier.convertToPlaylist(playlistId);
    }

    detailNotifier.reload();
    onConverted?.call(targetType);
  }

  void _removeLocal(String trackId) {
    setState(() => _tracks.removeWhere((t) => t.id == trackId));
  }

  @override
  Widget build(BuildContext context) {
    final currentCoverUrl = ref
        .watch(playlistDetailProvider)
        .playlist
        ?.coverUrl;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            children: [
              const BottomSheetHandle(),

              // ── Top bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    TextButton(
                      key: const Key('edit_playlist_cancel_button'),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit playlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const Key('edit_playlist_save_button'),
                      onPressed: _isSaving ? null : _onSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // ── Cover picker ────────────────────────────────────
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: ElevatedButton(
                            key: const Key('edit_playlist_cover_picker'),
                            onPressed: _openImagePicker,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: const Color(0xFF222222),
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_pickedCoverFile != null)
                                  Image.file(
                                    _pickedCoverFile!,
                                    fit: BoxFit.cover,
                                  )
                                else if (currentCoverUrl != null &&
                                    currentCoverUrl.isNotEmpty)
                                  _buildExistingCover(currentCoverUrl)
                                else
                                  const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white54,
                                      size: 36,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Fields ──────────────────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Playlist name ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            key: const Key('edit_playlist_name_field'),
                            controller: _nameController,
                            onSubmitted: (_) => _onSave(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                          TextField(
                            key: const Key('edit_playlist_description_field'),
                            controller: _descController,
                            onSubmitted: (_) => _onSave(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe your playlist',
                              hintStyle: TextStyle(color: Colors.grey[700]),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Make public',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                key: const Key('edit_playlist_public_switch'),
                                value: _isPublic,
                                onChanged: _isSaving
                                    ? null
                                    : (v) => setState(() => _isPublic = v),
                                activeThumbColor: const Color(0xFFFF5500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Convert To ───────────────────────────────────────
                    // Playlist → Album  |  Album → Playlist
                    // Station removed — no backend implementation
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'CONVERT TO',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Playlist → Album
                          if (_currentType == PlaylistType.playlist)
                            _ConvertTile(
                              key: const Key('edit_convert_to_album'),
                              icon: Icons.album,
                              label: 'Convert to Album',
                              sublabel: 'Shows release year in the header',
                              onTap: () => _showConvertConfirm(
                                context,
                                targetType: PlaylistType.album,
                                label: 'album',
                              ),
                            ),
                          // Album → Playlist
                          if (_currentType == PlaylistType.album)
                            _ConvertTile(
                              key: const Key('edit_convert_to_playlist'),
                              icon: Icons.queue_music,
                              label: 'Convert to Playlist',
                              sublabel:
                                  'Removes album label, moves to Playlists',
                              onTap: () => _showConvertConfirm(
                                context,
                                targetType: PlaylistType.playlist,
                                label: 'playlist',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Track list ───────────────────────────────────────
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tracks.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _tracks.removeAt(oldIndex);
                          _tracks.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final track = _tracks[index];
                        return _EditTrackRow(
                          key: Key('edit_track_row_${track.id}'),
                          track: track,
                          onRemove: () => _removeLocal(track.id),
                        );
                      },
                    ),

                    // Bottom padding for player bar
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExistingCover(String url) {
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.camera_alt, color: Colors.white54, size: 36),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.camera_alt, color: Colors.white54, size: 36),
    );
  }

  void _showConvertConfirm(
    BuildContext context, {
    required PlaylistType targetType,
    required String label,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Convert to $label?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _convertDescription(targetType),
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        actions: [
          TextButton(
            key: Key('convert_cancel_$label'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            key: Key('convert_confirm_$label'),
            onPressed: () => _convert(dialogContext, targetType),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5500),
            ),
            child: Text('Convert to $label'),
          ),
        ],
      ),
    );
  }

  String _convertDescription(PlaylistType type) {
    switch (type) {
      case PlaylistType.album:
        return 'Moves this to your Albums section and shows the release year in the header.';
      case PlaylistType.playlist:
        return 'Moves this back to your Playlists section and removes the album label.';
      case PlaylistType.station:
        return '';
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ConvertTile extends StatelessWidget {
  const _ConvertTile({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EditTrackRow extends StatelessWidget {
  const _EditTrackRow({super.key, required this.track, required this.onRemove});

  final PlaylistTrack track;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Row(
        children: [
          IconButton(
            key: Key('edit_track_remove_${track.id}'),
            icon: const Icon(
              Icons.remove_circle,
              color: Colors.redAccent,
              size: 26,
            ),
            onPressed: onRemove,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: 55,
              height: 55,
              child: track.coverUrl != null
                  ? Image.network(track.coverUrl!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: track.isUnavailable
                        ? Colors.grey[600]
                        : Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (track.artistName.isNotEmpty)
                  Text(
                    track.artistName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                if (track.isUnavailable)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      Text(
                        ' Not available',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  )
                else
                  Text(
                    '${track.formattedPlayCount} · ${track.formattedDuration}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.drag_handle, color: Colors.grey, size: 22),
          ),
        ],
      ),
    );
  }
}
