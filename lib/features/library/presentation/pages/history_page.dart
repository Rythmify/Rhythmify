import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';

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
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = ref.read(historyProvider);
        if (state.isLoading || !state.hasMore) return;
        ref.read(historyProvider.notifier).load();
      }
    } catch (_) {
      // If the controller is not attached or throws while disposing, ignore.
    }
  }

  @override
  void dispose() {
    // Remove the listener first to avoid it firing during dispose and
    // attempting to access Riverpod providers after the widget has been
    // unmounted, which causes exceptions.
    try {
      _scrollController.removeListener(_onScroll);
    } catch (_) {}
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            key: const Key('clear_history_dialog_cancel_button'),
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(false);
              }
            },
            child: Text('Cancel', style: AppTheme.labelLarge),
          ),
          TextButton(
            key: const Key('clear_history_dialog_clear_button'),
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(historyProvider.notifier).clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('history_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarItems),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _searchBar(
          key: const Key('history_search_bar'),
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          IconButton(
            key: const Key('history_filter_button'),
            icon: const Icon(Icons.tune, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('history_cast_button'),
            icon: const Icon(Icons.cast, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(historyProvider.notifier).load(refresh: true),
        child: state.isLoading && state.entries.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              )
            : _buildScrollView(context, state),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, HistoryState state) {
    final filtered = _query.isEmpty
        ? state.entries
        : state.entries
              .where(
                (e) => e.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    final filteredTracks = filtered
        .map(
          (entry) => Track(
            id: entry.trackId,
            userId: entry.userId,
            title: entry.title,
            artist: entry.artistName,
            audioUrl: entry.audioUrl ?? '',
            streamUrl: entry.streamUrl,
            duration: Duration(seconds: entry.durationSeconds),
            playCount: entry.playCount,
            isLiked: entry.isLiked,
            isArtistFollowed: entry.isArtistFollowed,
            createdAt: entry.playedAt,
            coverImage: entry.artworkUrl,
          ),
        )
        .toList();

    void playAt(int index) {
      if (filteredTracks.isEmpty) return;
      ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: filteredTracks,
            initialIndex: index,
            context: const QueueContext(type: QueueSource.listeningHistory),
          );
    }

    return CustomScrollView(
      key: const Key('history_scroll_view'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _historyHeader(
            onClear: _confirmClear,
            onShuffle: () {
              if (filteredTracks.isNotEmpty) {
                final shuffled = List<Track>.from(filteredTracks)..shuffle();
                ref
                    .read(queueStateProvider.notifier)
                    .playQueue(
                      tracks: shuffled,
                      initialIndex: 0,
                      context: const QueueContext(
                        type: QueueSource.listeningHistory,
                      ),
                    );
              }
            },
            onPlay: () => playAt(0),
          ),
        ),

        if (filtered.isEmpty && !state.isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 120),
            sliver: SliverList.builder(
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return state.isLoading
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

                return TrackCard(
                  key: Key('history_item_${filteredTracks[index].id}_$index'),
                  track: filteredTracks[index],
                  onTap: () => playAt(index),
                );
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // Local _searchBar used in AppBar
  Widget _searchBar({
    required Key key,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      key: key,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(19),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search in your history',
          hintStyle: AppTheme.bodyMedium,
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  // Header similar to Likes header but for history
  Widget _historyHeader({
    required VoidCallback onClear,
    required VoidCallback onShuffle,
    required VoidCallback onPlay,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Listening History',
              style: AppTheme.headlineLarge.copyWith(height: 1),
            ),
          ),
          IconButton(
            key: const Key('history_clear_icon_button'),
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.textSecondary,
            ),
            onPressed: onClear,
          ),
          IconButton(
            key: const Key('history_shuffle_icon_button'),
            icon: const Icon(Icons.shuffle, color: AppTheme.textSecondary),
            onPressed: onShuffle,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            key: const Key('history_play_button'),
            onTap: onPlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
