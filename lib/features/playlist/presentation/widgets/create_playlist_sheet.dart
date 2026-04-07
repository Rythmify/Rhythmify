// ============================================================
// CreatePlaylistSheet
// ============================================================
// This is the small bottom sheet shown in Image 5.
// It has:
//   - A name text field (pre-filled with "Untitled playlist")
//   - A character counter (17/100)
//   - A "Make this playlist public" toggle
//   - A "Create playlist" button
//   - A "Cancel" text button
//
// HOW TO SHOW IT:
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => const CreatePlaylistSheet(),
//   );
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/playlist_provider.dart';
import 'playlist_shared_widgets.dart';

class CreatePlaylistSheet extends ConsumerStatefulWidget {
  const CreatePlaylistSheet({super.key, this.onCreated});

  /// Called after the playlist is created with the new playlist's ID.
  /// The caller uses this to navigate to the new playlist's detail page.
  final void Function(String playlistId)? onCreated;

  @override
  ConsumerState<CreatePlaylistSheet> createState() =>
      _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends ConsumerState<CreatePlaylistSheet> {
  late final TextEditingController _nameController;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: 'Untitled playlist');
    // Select all text so user can type immediately.
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

  void _onCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    // Create via the provider (which calls the mock store).
    final playlist = ref.read(playlistListProvider.notifier).createPlaylist(
          name: name,
          isPublic: _isPublic,
        );
    Navigator.of(context).pop();
    widget.onCreated?.call(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    // keyboardHeight pushes the sheet up when the keyboard opens.
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
          const BottomSheetHandle(),
          // ── Name field ──────────────────────────────────────
          TextField(
            key: const Key('create_playlist_name_field'),
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
          // ── Public toggle ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Make this playlist public',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              Switch(
                key: const Key('create_playlist_public_switch'),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                activeColor: const Color(0xFFFF5500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Create button ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              key: const Key('create_playlist_create_button'),
              onPressed: _nameController.text.trim().isEmpty ? null : _onCreate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Create playlist',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Cancel button ────────────────────────────────────
          TextButton(
            key: const Key('create_playlist_cancel_button'),
            onPressed: () => Navigator.of(context).pop(),
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