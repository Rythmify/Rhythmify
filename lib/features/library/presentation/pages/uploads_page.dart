import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Displays a paginated list of tracks uploaded by the authenticated user.
///
/// Shows status badges for processing/failed tracks.
/// Supports visibility toggle, deletion, and uploading new tracks.
class UploadsPage extends ConsumerStatefulWidget {
  const UploadsPage({super.key});

  @override
  ConsumerState<UploadsPage> createState() => _UploadsPageState();
}

class _UploadsPageState extends ConsumerState<UploadsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(uploadsProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your Uploads'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('uploads_new_upload_icon_button'),
            icon: const Icon(Icons.add),
            tooltip: 'Upload a track',
            onPressed: () => context.push('/upload-track'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(uploadsProvider.notifier).load(refresh: true),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UploadsState state) {
    if (state.isLoading && state.tracks.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand));
    }

    if (state.tracks.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppTheme.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text('No uploads yet', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Share your music with the world.', style: AppTheme.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('uploads_empty_upload_button'),
              onPressed: () => context.push('/upload-track'),
              icon: const Icon(Icons.add),
              label: const Text('Upload Track'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrand, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('uploads_list_view'),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.tracks.length + 1,
      itemBuilder: (context, index) {
        if (index == state.tracks.length) {
          return state.isLoading
              ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand, strokeWidth: 2)))
              : const SizedBox.shrink();
        }
        return _UploadTile(track: state.tracks[index]);
      },
    );
  }
}

class _UploadTile extends ConsumerWidget {
  final UploadedTrack track;

  const _UploadTile({required this.track});

  Future<void> _showOptions(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              key: Key('uploads_toggle_visibility_${track.id}_listtile'),
              leading: Icon(track.isPublic ? Icons.lock_outline : Icons.public, color: AppTheme.textSecondary),
              title: Text(track.isPublic ? 'Make private' : 'Make public', style: AppTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                ref.read(uploadsProvider.notifier).toggleVisibility(track.id, !track.isPublic);
              },
            ),
            ListTile(
              key: Key('uploads_delete_${track.id}_listtile'),
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete track', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: const Text('Delete track?', style: TextStyle(color: Colors.white)),
                    content: Text('Delete "${track.title}"? This cannot be undone.', style: AppTheme.bodyMedium),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTheme.labelLarge)),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirm == true) ref.read(uploadsProvider.notifier).deleteTrack(track.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: track.artworkUrl != null
                ? CachedNetworkImage(imageUrl: track.artworkUrl!, width: 56, height: 56, fit: BoxFit.cover, errorWidget: (c, u, e) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, key: Key('uploads_item_${track.id}_title_text'), style: AppTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (track.isProcessing)
                      _badge('Processing', Colors.orange)
                    else if (track.isFailed)
                      _badge('Failed', Colors.red)
                    else ...[
                      _badge(track.isPublic ? 'Public' : 'Private', track.isPublic ? Colors.green : AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      const Icon(Icons.play_arrow, size: 13, color: AppTheme.textSecondary),
                      Text(' ${_fmt(track.playCount)}', style: AppTheme.labelSmall),
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite_border, size: 13, color: AppTheme.textSecondary),
                      Text(' ${track.likeCount}', style: AppTheme.labelSmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // More button
          IconButton(
            key: Key('uploads_item_${track.id}_more_icon_button'),
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
            onPressed: () => _showOptions(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(width: 56, height: 56, color: AppTheme.surface, child: const Icon(Icons.music_note, color: AppTheme.textSecondary, size: 24));

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.5))),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  String _fmt(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
