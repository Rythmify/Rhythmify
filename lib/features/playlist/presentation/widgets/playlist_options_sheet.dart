/// The ··· options sheet shown from any playlist, album, or station.
/// Owner-only actions (Edit, Delete, privacy toggle) are gated behind [isOwner].
/// [onConverted] is forwarded to [EditPlaylistSheet] so the detail screen
/// can navigate to the correct Library tab after a type conversion.
/// Share actions are stubbed and ready for the share module integration.
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

  /// Called after a conversion with the new type.
  /// Passed through to [EditPlaylistSheet] so the detail screen can navigate.
  final void Function(PlaylistType newType)? onConverted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Preview row
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
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Share section
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
                SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 26,
                              ),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                    _ShareBtn(
                      key: const Key('options_share_sms'),
                      icon: Icons.message_outlined,
                      label: 'SMS',
                      onTap: () {},
                    ),
                    _ShareBtn(
                      key: const Key('options_share_qr'),
                      icon: Icons.qr_code,
                      label: 'QR code',
                      onTap: () {},
                    ),
                    _ShareBtn(
                      key: const Key('options_share_copy'),
                      icon: Icons.copy,
                      label: 'Copy link',
                      onTap: () {},
                    ),
                    _ShareBtn(
                      key: const Key('options_share_whatsapp'),
                      icon: Icons.chat_bubble,
                      label: 'WhatsApp',
                      color: Colors.green,
                      onTap: () {},
                    ),
                    _ShareBtn(
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
          // Actions
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
                    // Pass onConverted through so the detail screen can navigate
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
                ref
                    .read(playlistListProvider.notifier)
                    .updatePlaylist(
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
                Navigator.of(context).pop();
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

class _ShareBtn extends StatelessWidget {
  const _ShareBtn({
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
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}
