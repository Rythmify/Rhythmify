// lib/features/playlist/presentation/widgets/playlist_options_sheet.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import 'edit_playlist_sheet.dart';
import 'playlist_shared_widgets.dart';

class PlaylistOptionsSheet extends ConsumerWidget {
  const PlaylistOptionsSheet({
    super.key,
    required this.playlistId,
    this.playlist, // FIX: optional pre-loaded entity from library screen
    this.isOwner = false,
    this.onConverted,
  });

  final String playlistId;
  final PlaylistEntity?
  playlist; // passed from library to avoid wrong playlist bug
  final bool isOwner;
  final void Function(PlaylistType newType)? onConverted;

  String _buildShareUrl(PlaylistEntity p) =>
      'https://rythmify.com/playlists/${p.id}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: use the passed playlist entity if available (from library),
    // otherwise fall back to playlistDetailProvider (from detail screen).
    final detailState = ref.watch(playlistDetailProvider);
    final resolvedPlaylist = playlist ?? detailState.playlist;

    if (resolvedPlaylist == null) return const SizedBox.shrink();

    // For like state: use detailState if we opened from detail screen,
    // otherwise use the entity's own isLiked field.
    final isLiked = playlist != null
        ? resolvedPlaylist.isLiked
        : detailState.isLiked;

    final sheetContext = context;
    final shareUrl = _buildShareUrl(resolvedPlaylist);

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

            // ── Preview row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  PlaylistCoverImage(
                    playlist: resolvedPlaylist,
                    size: 56,
                    borderRadius: 4,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedPlaylist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          resolvedPlaylist.ownerName.isNotEmpty
                              ? resolvedPlaylist.ownerName
                              : 'You',
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

            // ── Share row ──────────────────────────────────────────────
            _ShareRow(shareUrl: shareUrl, playlist: resolvedPlaylist),

            const Divider(color: Colors.white12, height: 1),

            // ── Like ──────────────────────────────────────────────────────
            OptionSheetTile(
              key: const Key('options_like'),
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              label: isLiked ? 'Liked' : 'Like',
              color: isLiked ? const Color(0xFFFF5500) : Colors.white,
              onTap: () async {
                Navigator.of(context).pop();
                // If opened from detail screen, use the notifier
                if (playlist == null) {
                  await ref.read(playlistDetailProvider.notifier).toggleLike();
                }
                // If opened from library, the like state is read-only here.
                // User should open the playlist detail to like/unlike.
              },
            ),

            // ── Play next ─────────────────────────────────────────────────
            OptionSheetTile(
              key: const Key('options_play_next'),
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () async {
                Navigator.of(context).pop();
                final tracks = detailState.tracks;
                if (tracks.isEmpty) return;
                try {
                  final t = await ref
                      .read(getTrackDetailsUseCaseProvider)
                      .call(tracks.first.id);
                  await ref
                      .read(playerStateProvider.notifier)
                      .addToQueueNext(t);
                } catch (_) {}
              },
            ),

            // ── Play last ─────────────────────────────────────────────────
            OptionSheetTile(
              key: const Key('options_play_last'),
              icon: Icons.add_to_queue,
              label: 'Play last',
              onTap: () async {
                Navigator.of(context).pop();
                final tracks = detailState.tracks;
                if (tracks.isEmpty) return;
                try {
                  final t = await ref
                      .read(getTrackDetailsUseCaseProvider)
                      .call(tracks.first.id);
                  await ref
                      .read(playerStateProvider.notifier)
                      .addToQueueLast(t);
                } catch (_) {}
              },
            ),

            // ── Copy ─────────────────────────────────────────────────────
            // Works for owned playlists, mixes, and track radios.
            // Creates a new owned playlist with the same tracks.
            OptionSheetTile(
              key: const Key('options_copy'),
              icon: Icons.copy_all,
              label: 'Copy ${resolvedPlaylist.typeLabel.toLowerCase()}',
              onTap: () async {
                Navigator.of(context).pop();
                _showCopyingSnackbar(sheetContext);
                final newId = await ref
                    .read(playlistListProvider.notifier)
                    .copyPlaylist(playlistId);
                if (newId != null && sheetContext.mounted) {
                  ScaffoldMessenger.of(sheetContext).hideCurrentSnackBar();
                  // Navigate to the new owned playlist with full edit UI
                  sheetContext.push('/library/playlists/$newId', extra: true);
                }
              },
            ),

            if (isOwner) ...[
              // ── Edit ───────────────────────────────────────────────────
              OptionSheetTile(
                key: const Key('options_edit'),
                icon: Icons.edit_outlined,
                label: 'Edit ${resolvedPlaylist.typeLabel.toLowerCase()}',
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

              // ── Toggle privacy ─────────────────────────────────────────
              OptionSheetTile(
                key: const Key('options_toggle_privacy'),
                icon: resolvedPlaylist.isPublic
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
                label: resolvedPlaylist.isPublic
                    ? 'Make ${resolvedPlaylist.typeLabel.toLowerCase()} private'
                    : 'Make ${resolvedPlaylist.typeLabel.toLowerCase()} public',
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref
                      .read(playlistListProvider.notifier)
                      .updatePlaylist(
                        playlistId: playlistId,
                        name: resolvedPlaylist.name,
                        isPublic: !resolvedPlaylist.isPublic,
                      );
                  ref.read(playlistDetailProvider.notifier).reload();
                },
              ),

              // ── Delete ─────────────────────────────────────────────────
              OptionSheetTile(
                key: const Key('options_delete'),
                icon: Icons.delete_outline,
                label: 'Delete ${resolvedPlaylist.typeLabel.toLowerCase()}',
                color: Colors.redAccent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: Text(
                        'Delete ${resolvedPlaylist.typeLabel.toLowerCase()}?',
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

  void _showCopyingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating copy...'),
        duration: Duration(seconds: 10),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHARE ROW
// ════════════════════════════════════════════════════════════════════════════

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.shareUrl, required this.playlist});

  final String shareUrl;
  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHARE',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ShareIcon(
                  icon: Icons.send_outlined,
                  label: 'Message',
                  onTap: () => Share.share(shareUrl, subject: playlist.name),
                ),
                _ShareIcon(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  onTap: () => Share.share(shareUrl, subject: playlist.name),
                ),
                _ShareIcon(
                  icon: Icons.qr_code_2,
                  label: 'QR code',
                  onTap: () => _showQrCode(context),
                ),
                _ShareIcon(
                  icon: Icons.link,
                  label: 'Copy link',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ShareIcon(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  backgroundColor: const Color(0xFF25D366),
                  onTap: () => Share.share(shareUrl, subject: playlist.name),
                ),
                _ShareIcon(
                  icon: Icons.photo_camera,
                  label: 'Snapchat',
                  backgroundColor: const Color(0xFFFFFC00),
                  iconColor: Colors.black,
                  onTap: () => Share.share(shareUrl, subject: playlist.name),
                ),
                _ShareIcon(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => Share.share(shareUrl, subject: playlist.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQrCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => _QrCodeSheet(url: shareUrl, playlistName: playlist.name),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCodeSheet extends StatelessWidget {
  const _QrCodeSheet({required this.url, required this.playlistName});

  final String url;
  final String playlistName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 8),
          Text(
            playlistName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 160, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            url,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Link copied')));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
              ),
              child: const Text(
                'Copy link',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
