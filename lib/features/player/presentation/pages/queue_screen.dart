import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../providers/queue_provider.dart';
import '../../domain/entities/queue_item.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(queueStateProvider);
    
    final history = queueState.history;
    final current = queueState.currentTrack;
    final allUpcoming = queueState.upcomingTracks;

    // Split upcoming into manual vs auto-discovery
    final manualUpcoming = allUpcoming.where((t) => !t.isRecommended).toList();
    final recommended = allUpcoming.where((t) => t.isRecommended).toList();

    if (current == null && allUpcoming.isEmpty && history.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('Queue is empty', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Queue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('player_queue_shuffle_icon_button'),
            icon: Icon(
              queueState.isShuffled ? Icons.shuffle_on : Icons.shuffle,
              color: queueState.isShuffled
                  ? AppTheme.primaryBrand
                  : Colors.white,
            ),
            onPressed: () {
              ref.read(queueStateProvider.notifier).toggleShuffle();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // --- HISTORY SECTION ---
          if (history.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recently Played',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = history[index];
                  return Opacity(
                    opacity: 0.5,
                    child: _QueueTile(
                      item: item,
                      isHistory: true,
                      onTap: () {},
                    ),
                  );
                },
                childCount: history.length,
              ),
            ),
          ],

          // --- CURRENT SECTION ---
          if (current != null) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Now Playing',
                  style: TextStyle(
                    color: AppTheme.primaryBrand,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _QueueTile(
                item: current,
                isActive: true,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],

          // --- UPCOMING SECTION ---
          if (manualUpcoming.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Next Up',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverReorderableList(
              itemCount: manualUpcoming.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(queueStateProvider.notifier).reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = manualUpcoming[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(item.queueItemId ?? item.track.id + index.toString()),
                  index: index,
                  child: _QueueTile(
                    item: item,
                    onTap: () {
                      ref.read(queueStateProvider.notifier).playFromQueue(index);
                    },
                  ),
                );
              },
            ),
          ],

          // --- RECOMMENDED SECTION ---
          if (recommended.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = recommended[index];
                  return _QueueTile(
                    item: item,
                    onTap: () {
                      ref.read(queueStateProvider.notifier).playFromRecommended(index);
                    },
                  );
                },
                childCount: recommended.length,
              ),
            ),
          ],

          if (queueState.isLoadingRecommendations)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryBrand,
                  ),
                ),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final QueueItem item;
  final bool isActive;
  final bool isHistory;
  final VoidCallback onTap;

  const _QueueTile({
    required this.item,
    this.isActive = false,
    this.isHistory = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (!isHistory && !isActive) ...[
              const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: IgnorePointer(
                child: TrackCard(
                  track: item.track,
                ),
              ),
            ),
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.equalizer, color: AppTheme.primaryBrand),
              ),
          ],
        ),
      ),
    );
  }
}
