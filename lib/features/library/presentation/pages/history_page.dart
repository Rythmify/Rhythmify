import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Full paginated listening history with clear-all action.
///
/// Groups entries by date (Today, Yesterday, Older).
/// Pull-to-refresh reloads from page 1.
/// Scrolling near the bottom loads the next page.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(historyProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear history?', style: TextStyle(color: Colors.white)),
        content: Text('This will permanently delete your entire listening history.', style: AppTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTheme.labelLarge)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) ref.read(historyProvider.notifier).clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Listening History'),
        centerTitle: false,
        actions: [
          if (state.entries.isNotEmpty)
            IconButton(
              key: const Key('history_clear_icon_button'),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(historyProvider.notifier).load(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isClearing) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand));
    }

    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand));
    }

    if (state.entries.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, color: AppTheme.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text('No listening history', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Tracks you play will appear here.', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    // Group entries by date label
    final grouped = _group(state.entries);
    final sections = grouped.keys.toList();

    return ListView.builder(
      key: const Key('history_list_view'),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: sections.length + 1, // +1 for pagination footer
      itemBuilder: (context, sectionIndex) {
        if (sectionIndex == sections.length) {
          return state.isLoading
              ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand, strokeWidth: 2)))
              : const SizedBox.shrink();
        }
        final label = sections[sectionIndex];
        final entries = grouped[label]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(label, style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
            ),
            ...entries.map((e) => _HistoryTile(entry: e)),
          ],
        );
      },
    );
  }

  /// Groups entries into Today / Yesterday / This Week / Older buckets.
  Map<String, List<RecentlyPlayedEntry>> _group(List<RecentlyPlayedEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final result = <String, List<RecentlyPlayedEntry>>{};

    for (final e in entries) {
      final d = DateTime(e.playedAt.year, e.playedAt.month, e.playedAt.day);
      final String label;
      if (!d.isBefore(today)) {
        label = 'Today';
      } else if (!d.isBefore(yesterday)) {
        label = 'Yesterday';
      } else if (!d.isBefore(weekAgo)) {
        label = 'This Week';
      } else {
        label = 'Older';
      }
      result.putIfAbsent(label, () => []).add(e);
    }
    return result;
  }
}

class _HistoryTile extends StatelessWidget {
  final RecentlyPlayedEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('history_item_${entry.trackId}_${entry.playedAt.millisecondsSinceEpoch}_list_tile'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: entry.artworkUrl != null
            ? CachedNetworkImage(
                imageUrl: entry.artworkUrl!,
                width: 48, height: 48, fit: BoxFit.cover,
                errorWidget: (c, u, e) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        entry.title,
        key: Key('history_item_${entry.trackId}_title_text'),
        style: AppTheme.labelLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.artistName,
        key: Key('history_item_${entry.trackId}_artist_text'),
        style: AppTheme.labelSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _relativeTime(entry.playedAt),
        key: Key('history_item_${entry.trackId}_time_text'),
        style: AppTheme.labelSmall,
      ),
    );
  }

  Widget _placeholder() => Container(width: 48, height: 48, color: AppTheme.surface, child: const Icon(Icons.music_note, color: AppTheme.textSecondary, size: 20));

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
