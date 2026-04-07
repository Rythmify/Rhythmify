// ============================================================
// PlaylistOptionsSheet
// ============================================================
// This is the bottom sheet shown in Image 4 when user taps ···.
// It shows:
//   - Playlist preview (cover + title + owner)
//   - "SEND TO" section with a friend avatar row
//   - "SHARE" section with SMS, QR code, Copy link, WhatsApp, Snapchat, More
//   - Action list: Like, Play next, Play last, Copy playlist,
//     Edit playlist, Make private/public, Delete playlist
//
// Album and Station use the SAME sheet — only "Edit playlist" label
// changes to "Edit album" or "Edit station".
//
// HOW TO SHOW IT:
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => PlaylistOptionsSheet(
//       playlistId: 'pl-001',
//       isOwner: true,
//     ),
//   );
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/playlist_provider.dart';
import '../screens/playlist_detail_screen.dart';
import 'edit_playlist_sheet.dart';
import 'playlist_shared_widgets.dart';

class PlaylistOptionsSheet extends ConsumerWidget {
  const PlaylistOptionsSheet({
    super.key,
    required this.playlistId,
    this.isOwner = false,
  });

  final String playlistId;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We read the detail state to get the playlist info for the preview row.
    final detailState = ref.watch(playlistDetailProvider(playlistId));
    final playlist = detailState.playlist;
    if (playlist == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          // ── Preview row ──────────────────────────────────────
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
          // ── SEND TO section ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEND TO',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // Friend avatars — horizontal scroll
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 1, // replace with real friend list
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[800],
                            child: const Icon(Icons.person,
                                color: Colors.grey, size: 26),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'rana ahm...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── SHARE section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHARE',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShareButton(
                      key: const Key('options_share_sms'),
                      icon: Icons.message_outlined,
                      label: 'SMS',
                      onTap: () {},
                    ),
                    _ShareButton(
                      key: const Key('options_share_qr'),
                      icon: Icons.qr_code,
                      label: 'QR code',
                      onTap: () {},
                    ),
                    _ShareButton(
                      key: const Key('options_share_copy_link'),
                      icon: Icons.copy,
                      label: 'Copy link',
                      onTap: () {},
                    ),
                    _ShareButton(
                      key: const Key('options_share_whatsapp'),
                      icon: Icons.chat_bubble,
                      label: 'WhatsApp',
                      color: Colors.green,
                      onTap: () {},
                    ),
                    _ShareButton(
                      key: const Key('options_share_more'),
                      icon: Icons.more_horiz,
                      label: 'More',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // ── Action list ──────────────────────────────────────
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
            key: const Key('options_copy_playlist'),
            icon: Icons.copy_all,
            label: 'Copy ${playlist.typeLabel.toLowerCase()}',
            onTap: () => Navigator.of(context).pop(),
          ),
          if (isOwner) ...[
            OptionSheetTile(
              key: const Key('options_edit_playlist'),
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
              key: const Key('options_delete_playlist'),
              icon: Icons.delete_outline,
              label: 'Delete ${playlist.typeLabel.toLowerCase()}',
              color: Colors.redAccent,
              onTap: () {
                Navigator.of(context).pop();
                // Pop the detail screen too then delete.
                Navigator.of(context).pop();
                ref
                    .read(playlistListProvider.notifier)
                    .deletePlaylist(playlistId);
              },
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }
}