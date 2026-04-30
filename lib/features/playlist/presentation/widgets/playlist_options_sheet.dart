// lib/features/playlist/presentation/widgets/playlist_options_sheet.dart
/// This file contains the playlist options bottom sheet shown for playlists,
/// albums, and mixes.
///
/// Features:
/// - Like/unlike playlists
/// - Share playlist links
/// - Copy playlist link
/// - Show QR code sharing sheet
/// - Queue playlist tracks (play next/play last)
/// - Copy playlists
/// - Edit playlists
/// - Change playlist privacy
/// - Delete playlists
///
/// Main Components:
/// - PlaylistOptionsSheet:
///     Main options bottom sheet widget.
///
/// - _CopyPlaylistSheet:
///     Bottom sheet used to duplicate/copy playlists.
///
/// - _ShareRow:
///     Displays sharing options.
///
/// - _QrCodeSheet:
///     Displays a simple QR-style share sheet.
///
/// - _ShareIcon:
///     Reusable share action button widget.
///
/// Dependencies:
/// - Riverpod providers
/// - GoRouter navigation
/// - Share Plus package
/// - Playlist entities/providers
/// - Player providers
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
    this.playlist,
    this.isOwner = false,
    this.onConverted,
    this.onDeleted,
  });

  final String playlistId;
  final PlaylistEntity? playlist;
  final bool isOwner;
  final void Function(PlaylistType newType)? onConverted;
  final VoidCallback? onDeleted;

  String _buildShareUrl(PlaylistEntity p) =>
      'https://rythmify.com/playlists/${p.id}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(playlistDetailProvider);
    final resolvedPlaylist = playlist ?? detailState.playlist;

    if (resolvedPlaylist == null) return const SizedBox.shrink();

    final isLiked = playlist != null
        ? resolvedPlaylist.isLiked
        : detailState.isLiked;

    final shareUrl = _buildShareUrl(resolvedPlaylist);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.40,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetHandle(),

              // ── Preview row ────────────────────────────────────────────
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

              _ShareRow(shareUrl: shareUrl, playlist: resolvedPlaylist),

              const Divider(color: Colors.white12, height: 1),

              // ── Like ────────────────────────────────────────────────────
              OptionSheetTile(
                key: const Key('options_like'),
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: isLiked ? 'Liked' : 'Like',
                color: isLiked ? const Color(0xFFFF5500) : Colors.white,
                onTap: () async {
                  Navigator.of(context).pop();
                  if (playlist == null) {
                    await ref
                        .read(playlistDetailProvider.notifier)
                        .toggleLike();
                  }
                },
              ),

              // ── Play next ──────────────────────────────────────────────
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

              // ── Play last ──────────────────────────────────────────────
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

              // ── Copy ────────────────────────────────────────────────────
              OptionSheetTile(
                key: const Key('options_copy'),
                icon: Icons.copy_all,
                label: 'Copy ${resolvedPlaylist.typeLabel.toLowerCase()}',
                onTap: () {
                  Navigator.of(context).pop();
                  // Small delay so sheet fully dismisses before next one opens
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _CopyPlaylistSheet(
                        sourceEntity: resolvedPlaylist,
                        onCreated: (newId) {
                          context.push(
                            '/library/playlists/$newId',
                            extra: true,
                          );
                        },
                      ),
                    );
                  });
                },
              ),

              if (isOwner) ...[
                // ── Edit ──────────────────────────────────────────────────
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
                  onTap: () =>
                      _showDeleteConfirm(context, ref, resolvedPlaylist),
                ),
              ],

              SizedBox(height: MediaQuery.of(context).padding.bottom + 120),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext sheetContext,
    WidgetRef ref,
    PlaylistEntity resolvedPlaylist,
  ) {
    showDialog<void>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(sheetContext).pop();
              ref
                  .read(playlistListProvider.notifier)
                  .deletePlaylist(playlistId);
              onDeleted?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COPY PLAYLIST SHEET
// ════════════════════════════════════════════════════════════════════════════

class _CopyPlaylistSheet extends ConsumerStatefulWidget {
  const _CopyPlaylistSheet({
    required this.sourceEntity,
    required this.onCreated,
  });

  final PlaylistEntity sourceEntity;
  final void Function(String newPlaylistId) onCreated;

  @override
  ConsumerState<_CopyPlaylistSheet> createState() => _CopyPlaylistSheetState();
}

class _CopyPlaylistSheetState extends ConsumerState<_CopyPlaylistSheet> {
  late final TextEditingController _nameController;
  late bool _isPublic;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.sourceEntity.isPublic;
    _nameController = TextEditingController(
      text: 'Copy of ${widget.sourceEntity.name}',
    );
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

  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isCreating) return;
    setState(() => _isCreating = true);

    final newId = await ref
        .read(playlistListProvider.notifier)
        .copyPlaylist(
          widget.sourceEntity.id,
          overrideName: name,
          overridePublic: _isPublic,
          sourceEntity: widget.sourceEntity,
        );

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (newId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create playlist. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    widget.onCreated(newId);
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
                value: _isPublic,
                onChanged: _isCreating
                    ? null
                    : (v) => setState(() => _isPublic = v),
                activeThumbColor: const Color(0xFFFF5500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _nameController.text.trim().isEmpty || _isCreating
                  ? null
                  : _onCreate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
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
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
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
