import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../../core/domain/entities/track.dart';

/// Listening history page matching SoundCloud's layout.
///
/// Structure:
/// - Delete (trash) icon + shuffle + play all action row
/// - [TrackCard] list using the shared widget
/// - Date-grouped headers (Today, Yesterday, This Week, Older)
/// - Pagination on scroll
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
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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
        title: const Text(
          'Clear history?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete your entire listening history.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTheme.labelLarge),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
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
        title: const Text('Listening history'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(historyProvider.notifier).load(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isClearing || (state.isLoading && state.entries.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      );
    }

    if (state.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, color: AppTheme.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text(
              'No listening history',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracks you play will appear here.',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Build flat list with date-label headers inserted
    final grouped = _group(state.entries);
    final sections = grouped.keys.toList();

    // Flatten into a mixed list of [String header | RecentlyPlayedEntry]
    final flatItems = <Object>[];
    for (final section in sections) {
      flatItems.add(section); // String header
      flatItems.addAll(grouped[section]!);
    }
    // Append pagination sentinel
    flatItems.add(_Sentinel(isLoading: state.isLoading));

    return Column(
      children: [
        // ── Action row: delete + shuffle + play ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                key: const Key('history_clear_icon_button'),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.textSecondary,
                ),
                tooltip: 'Clear history',
                onPressed: _confirmClear,
              ),
              const Spacer(),
              IconButton(
                key: const Key('history_shuffle_icon_button'),
                icon: const Icon(Icons.shuffle, color: AppTheme.textSecondary),
                onPressed: () {},
              ),
              FloatingActionButton.small(
                key: const Key('history_play_all_fab'),
                heroTag: 'history_play',
                backgroundColor: Colors.white,
                onPressed: () {},
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        // ── Track list ─────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            key: const Key('history_list_view'),
            controller: _scrollController,
            itemCount: flatItems.length,
            itemBuilder: (context, index) {
              final item = flatItems[index];

              // Date header
              if (item is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    item,
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              }

              // Pagination sentinel
              if (item is _Sentinel) {
                return item.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBrand,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              // Track row — convert RecentlyPlayedEntry → lightweight Track for TrackCard
              final entry = item as RecentlyPlayedEntry;
              final track = Track(
                id: entry.trackId,
                userId: '',
                title: entry.title,
                artist: entry.artistName,
                audioUrl: '',
                duration: Duration(seconds: entry.durationSeconds),
                createdAt: entry.playedAt,
                coverImage: entry.artworkUrl,
              );
              return TrackCard(
                key: Key(
                  'history_item_${entry.trackId}_${entry.playedAt.millisecondsSinceEpoch}',
                ),
                track: track,
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, List<RecentlyPlayedEntry>> _group(
    List<RecentlyPlayedEntry> entries,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final result = <String, List<RecentlyPlayedEntry>>{};
    for (final e in entries) {
      final d = DateTime(e.playedAt.year, e.playedAt.month, e.playedAt.day);
      final String label;
      if (!d.isBefore(today)) {
        label = 'Today';} 
      else if (!d.isBefore(yesterday)){
          label = 'Yesterday';}
      else if (!d.isBefore(weekAgo)){
        label = 'This Week';}
      else
      {label = 'Older';}
        
      result.putIfAbsent(label, () => []).add(e);
    }
    return result;
  }
}

class _Sentinel {
  final bool isLoading;
  const _Sentinel({required this.isLoading});
}
