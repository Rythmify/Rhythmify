/// The ··· options sheet shown from any playlist, album, or station.
/// Owner-only actions (Edit, Delete, privacy toggle) are gated behind [isOwner].
/// [onConverted] is forwarded to [EditPlaylistSheet] so the detail screen
/// can navigate to the correct Library tab after a type conversion.
/// Share will be wired when the share module is ready.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import 'edit_playlist_sheet.dart';
import 'playlist_shared_widgets.dart';

class PlaylistOptionsSheet extends ConsumerWidget {
  const PlaylistOptionsSheet({
    super.key,
    required this.playlistId,
    this.isOwner = false,
    this.onConverted,
  });

  final String playlistId;
  final bool isOwner;
  final void Function(PlaylistType newType)? onConverted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(playlistDetailProvider(playlistId));
    final playlist = detailState.playlist;
    if (playlist == null) return const SizedBox.shrink();

    final sheetContext = context;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 90,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),

            // ── Preview row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  PlaylistCoverImage(
                    playlist: playlist,
                    size: 56,
                    borderRadius: 4,
                  ),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          playlist.ownerName,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Actions ───────────────────────────────────────────────────
            OptionSheetTile(
              key: const Key('options_like'),
              icon: Icons.favorite_border,
              label: 'Like',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              key: const Key('options_play_next'),
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              key: const Key('options_play_last'),
              icon: Icons.add_to_queue,
              label: 'Play last',
              onTap: () => Navigator.of(context).pop(),
            ),
            OptionSheetTile(
              key: const Key('options_copy'),
              icon: Icons.copy_all,
              label: 'Copy ${playlist.typeLabel.toLowerCase()}',
              onTap: () => Navigator.of(context).pop(),
            ),

            if (isOwner) ...[
              OptionSheetTile(
                key: const Key('options_edit'),
                icon: Icons.edit_outlined,
                label: 'Edit ${playlist.typeLabel.toLowerCase()}',
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => EditPlaylistSheet(
                      playlistId: playlistId,
                      onConverted: onConverted,
                    ),
                  );
                },
              ),
              OptionSheetTile(
                key: const Key('options_toggle_privacy'),
                icon: Icons.lock_outline,
                label: playlist.isPublic
                    ? 'Make ${playlist.typeLabel.toLowerCase()} private'
                    : 'Make ${playlist.typeLabel.toLowerCase()} public',
                onTap: () {
                  ref.read(playlistListProvider.notifier).updatePlaylist(
                        playlistId: playlistId,
                        name: playlist.name,
                        isPublic: !playlist.isPublic,
                      );
                  Navigator.of(context).pop();
                },
              ),
              OptionSheetTile(
                key: const Key('options_delete'),
                icon: Icons.delete_outline,
                label: 'Delete ${playlist.typeLabel.toLowerCase()}',
                color: Colors.redAccent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: Text(
                        'Delete ${playlist.typeLabel.toLowerCase()}?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'This cannot be undone.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(sheetContext).pop();
                            ref
                                .read(playlistListProvider.notifier)
                                .deletePlaylist(playlistId);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}