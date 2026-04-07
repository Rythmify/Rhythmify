// ============================================================
// EditPlaylistSheet
// ============================================================
// This is the full-screen modal shown in Image 3.
// It has:
//   - Cancel / "Edit playlist" title / Save in the top bar
//   - Square cover image picker with camera icon overlay
//   - "Playlist name *" text field
//   - "Description" text field
//   - "Make public" toggle
//   - The list of current tracks with:
//       - Red [−] remove button on the left
//       - Drag handle (≡) on the right for reordering
//
// HOW TO SHOW IT:
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => EditPlaylistSheet(playlistId: 'pl-001'),
//   );
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playlist_track.dart';
import '../providers/playlist_provider.dart';
import 'playlist_shared_widgets.dart';

class EditPlaylistSheet extends ConsumerStatefulWidget {
  const EditPlaylistSheet({
    super.key,
    required this.playlistId,
  });

  final String playlistId;

  @override
  ConsumerState<EditPlaylistSheet> createState() => _EditPlaylistSheetState();
}

class _EditPlaylistSheetState extends ConsumerState<EditPlaylistSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late bool _isPublic;
  late List<PlaylistTrack> _tracks;

  @override
  void initState() {
    super.initState();
    // Read ONCE at init — we don't use ref.watch here because we
    // don't want the sheet to rebuild while the user is typing.
    final state =
        ref.read(playlistDetailProvider(widget.playlistId));
    _nameController =
        TextEditingController(text: state.playlist?.name ?? '');
    _descController =
        TextEditingController(text: state.playlist?.description ?? '');
    _isPublic = state.playlist?.isPublic ?? true;
    _tracks = List.from(state.tracks); // local copy we can mutate
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSave() {
    // 1. Save name / description / public via the list provider.
    ref.read(playlistListProvider.notifier).updatePlaylist(
          playlistId: widget.playlistId,
          name: _nameController.text.trim(),
          isPublic: _isPublic,
          description: _descController.text.trim(),
        );
    // 2. If the user removed tracks locally, sync removals.
    final originalTracks =
        ref.read(playlistDetailProvider(widget.playlistId)).tracks;
    for (final original in originalTracks) {
      if (!_tracks.any((t) => t.id == original.id)) {
        ref
            .read(playlistDetailProvider(widget.playlistId).notifier)
            .removeTrack(original.id);
      }
    }
    // 3. Reload the detail screen so changes appear immediately.
    ref
        .read(playlistDetailProvider(widget.playlistId).notifier)
        .reload();
    Navigator.of(context).pop();
  }

  // Remove a track from the LOCAL list (not yet saved until user taps Save).
  void _removeLocal(String trackId) {
    setState(() => _tracks.removeWhere((t) => t.id == trackId));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            children: [
              const BottomSheetHandle(),
              // ── Top bar: Cancel / Title / Save ──────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    TextButton(
                      key: const Key('edit_playlist_cancel_button'),
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _onSave,
                      child: const Text(
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
              // ── Scrollable body ──────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // ── Cover image picker ────────────────────
                    GestureDetector(
                      key: const Key('edit_playlist_cover_picker'),
                      onTap: () {
                        // open image picker
                        // For now this is a UI placeholder.
                      },
                      child: Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          color: const Color(0xFF222222),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white54,
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── Fields box ────────────────────────────
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
                          // Playlist name
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe your playlist',
                              hintStyle:
                                  TextStyle(color: Colors.grey[700]),
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Make public toggle
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                key: const Key(
                                    'edit_playlist_public_switch'),
                                value: _isPublic,
                                onChanged: (v) =>
                                    setState(() => _isPublic = v),
                                activeColor: const Color(0xFFFF5500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Track list with remove + drag ─────────
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tracks.length,
                      onReorder: (oldIndex, newIndex) {
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One row in the edit sheet's track list.
/// Left: red minus button. Right: drag handle (≡).
class _EditTrackRow extends StatelessWidget {
  const _EditTrackRow({
    super.key,
    required this.track,
    required this.onRemove,
  });

  final PlaylistTrack track;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Row(
        children: [
          // Red minus button
          IconButton(
            key: Key('edit_track_remove_${track.id}'),
            icon: const Icon(
              Icons.remove_circle,
              color: Colors.redAccent,
              size: 26,
            ),
            onPressed: onRemove,
          ),
          // Cover + title + artist
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
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                if (track.isUnavailable)
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 11, color: Colors.grey[600]),
                      Text(
                        ' Not available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${track.formattedPlayCount} · ${track.formattedDuration}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Drag handle — ReorderableListView uses this automatically
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.drag_handle, color: Colors.grey, size: 22),
          ),
        ],
      ),
    );
  }
}