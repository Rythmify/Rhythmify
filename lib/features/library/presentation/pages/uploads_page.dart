import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Your Uploads page matching SoundCloud's layout.
///
/// Empty state: centered icon + headline + body + "Upload a track" [OutlinedButton].
/// Loaded state: search bar + [ListView] of upload tiles with status badges.
class UploadsPage extends ConsumerStatefulWidget {
  const UploadsPage({super.key});

  @override
  ConsumerState<UploadsPage> createState() => _UploadsPageState();
}

class _UploadsPageState extends ConsumerState<UploadsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your uploads'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('uploads_new_upload_icon_button'),
            icon: const Icon(Icons.add),
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

    // ── Empty state matching SoundCloud screenshot ────────────────────────
    if (state.tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Purple gradient placeholder (matching the screenshot's gradient header)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A0080), Color(0xFF1A0040)],
                  ),
                ),
                child: const Icon(Icons.cloud_upload_outlined, color: Colors.white54, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                'No tracks uploaded yet',
                key: const Key('uploads_empty_headline_text'),
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tracks you\'ve uploaded will show up here',
                key: const Key('uploads_empty_body_text'),
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                key: const Key('uploads_empty_upload_button'),
                onPressed: () => context.push('/upload-track'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.textSecondary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Upload a track'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _query.isEmpty
        ? state.tracks
        : state.tracks.where((t) => t.title.toLowerCase().contains(_query.toLowerCase())).toList();

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(21)),
            child: TextField(
              key: const Key('uploads_search_text_field'),
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search in your uploads',
                hintStyle: AppTheme.bodyMedium,
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                suffixIcon: const Icon(Icons.tune, color: AppTheme.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),

        // ── Upload list ────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            key: const Key('uploads_list_view'),
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == filtered.length) {
                return state.isLoading
                    ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand, strokeWidth: 2)))
                    : const SizedBox.shrink();
              }
              return _UploadTile(track: filtered[index]);
            },
          ),
        ),
      ],
    );
  }
}

// ── Upload tile ────────────────────────────────────────────────────────────────

class _UploadTile extends ConsumerWidget {
  final UploadedTrack track;
  const _UploadTile({required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('uploads_item_${track.id}_list_tile'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: track.artworkUrl != null
            ? CachedNetworkImage(imageUrl: track.artworkUrl!, width: 52, height: 52, fit: BoxFit.cover, errorWidget: (c, u, e) => _placeholder())
            : _placeholder(),
      ),
      title: Text(
        track.title,
        key: Key('uploads_item_${track.id}_title_text'),
        style: AppTheme.labelLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (track.isProcessing)
            _badge('Processing', Colors.orange)
          else if (track.isFailed)
            _badge('Failed', Colors.red)
          else ...[
            const Icon(Icons.play_arrow, size: 13, color: AppTheme.textSecondary),
            Text(' ${_fmt(track.playCount)} · ${track.isPublic ? "Public" : "Private"}', style: AppTheme.labelSmall),
          ],
        ],
      ),
      trailing: IconButton(
        key: Key('uploads_item_${track.id}_more_icon_button'),
        icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
        onPressed: () => _showOptions(context, ref),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            ListTile(
              key: Key('uploads_toggle_visibility_${track.id}_listtile'),
              leading: Icon(track.isPublic ? Icons.lock_outline : Icons.public, color: AppTheme.textSecondary),
              title: Text(track.isPublic ? 'Make private' : 'Make public', style: AppTheme.bodyLarge),
              onTap: () { Navigator.pop(context); ref.read(uploadsProvider.notifier).toggleVisibility(track.id, !track.isPublic); },
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

  Widget _placeholder() => Container(width: 52, height: 52, color: AppTheme.lighterSurface, child: const Icon(Icons.music_note, color: AppTheme.textSecondary, size: 22));
  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.5))),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );
  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}