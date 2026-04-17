// lib/features/playlist/presentation/widgets/create_playlist_sheet.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/playlist_provider.dart';
import 'playlist_shared_widgets.dart';

class CreatePlaylistSheet extends ConsumerStatefulWidget {
  const CreatePlaylistSheet({super.key, this.onCreated});

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
    _nameController = TextEditingController(text: 'Untitled playlist');
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

  // async because createPlaylist now hits the real API and returns a Future.
  // We await it to get the real playlist ID assigned by the database.
  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final playlist = await ref
        .read(playlistListProvider.notifier)
        .createPlaylist(name: name, isPublic: _isPublic);

    if (!mounted) return;
    Navigator.of(context).pop();
    // playlist.id is now the real UUID from the database, not a mock ID
    widget.onCreated?.call(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isLoading = ref.watch(playlistListProvider).isLoading;

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
                activeThumbColor: const Color(0xFFFF5500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              key: const Key('create_playlist_create_button'),
              // Disable while loading to prevent double-taps
              onPressed: (_nameController.text.trim().isEmpty || isLoading)
                  ? null
                  : _onCreate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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