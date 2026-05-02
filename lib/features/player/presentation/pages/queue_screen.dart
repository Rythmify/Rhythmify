import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
    // 1. SELECT only the parts of the queue state we need for structural changes.
    // This prevents position ticks from triggering a full rebuild of the screen.
    final hasCurrent = ref.watch(
      queueStateProvider.select((s) => s.currentTrack != null),
    );
    final isShuffled = ref.watch(
      queueStateProvider.select((s) => s.isShuffled),
    );
    final isLoadingRecs = ref.watch(
      queueStateProvider.select((s) => s.isLoadingRecommendations),
    );

    // 2. Memoize the lists so we don't re-filter on every frame.
    final history = ref.watch(queueStateProvider.select((s) => s.history));
    final current = ref.watch(queueStateProvider.select((s) => s.currentTrack));
    final manualUpcoming = ref.watch(
      queueStateProvider.select(
        (s) => s.upcomingTracks.where((t) => !t.isRecommended).toList(),
      ),
    );
    final recommended = ref.watch(
      queueStateProvider.select(
        (s) => s.upcomingTracks.where((t) => t.isRecommended).toList(),
      ),
    );

    if (!hasCurrent && manualUpcoming.isEmpty && history.isEmpty) {
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
              isShuffled ? Icons.shuffle_on : Icons.shuffle,
              color: isShuffled ? AppTheme.primaryBrand : Colors.white,
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
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = history[index];
                return Opacity(
                  opacity: 0.5,
                  child: _QueueTile(item: item, isHistory: true, onTap: () {}),
                );
              }, childCount: history.length),
            ),
          ],

          // --- CURRENT SECTION ---
          if (hasCurrent && current != null) ...[
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
                ref
                    .read(queueStateProvider.notifier)
                    .reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = manualUpcoming[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(item.queueItemId),
                  index: index,
                  child: Material(
                    color: Colors.transparent,
                    child: _QueueTile(
                      item: item,
                      reorderableIndex: index,
                      onTap: () {
                        // Find this item's position in the FULL upcomingTracks
                        // list (which includes recommended tracks). Using the
                        // filtered-list index directly would be off-by-one
                        // whenever recommended tracks appear before this item.
                        final queue = ref.read(queueStateProvider);
                        final fullIndex = queue.upcomingTracks.indexOf(item);
                        if (fullIndex != -1) {
                          ref
                              .read(queueStateProvider.notifier)
                              .playFromQueue(fullIndex);
                        }
                      },
                    ),
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
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = recommended[index];
                return _QueueTile(
                  item: item,
                  showDragHandle: false,
                  onTap: () {
                    ref
                        .read(queueStateProvider.notifier)
                        .playFromRecommended(index);
                  },
                );
              }, childCount: recommended.length),
            ),
          ],

          if (isLoadingRecs)
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
  final bool showDragHandle;
  final int? reorderableIndex;
  final VoidCallback onTap;

  const _QueueTile({
    required this.item,
    this.isActive = false,
    this.isHistory = false,
    this.showDragHandle = true,
    this.reorderableIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final track = item.track;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          children: [
            // --- Artwork ---
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[900],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: track.coverImage != null
                    ? (track.coverImage!.startsWith('http')
                        ? Image.network(
                            track.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.music_note,
                              color: Colors.grey,
                              size: 20,
                            ),
                          )
                        : Image.asset(
                            track.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.music_note,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ))
                    : const Icon(
                        Icons.music_note,
                        color: Colors.grey,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // --- Smaller Text ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? AppTheme.primaryBrand : Colors.white,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            if (isActive)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.equalizer,
                  color: AppTheme.primaryBrand,
                  size: 18,
                ),
              ),

            // --- Drag Handle on the Right ---
            if (!isHistory && !isActive && showDragHandle)
              reorderableIndex != null
                  ? ReorderableDragStartListener(
                      index: reorderableIndex!,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: Icon(Icons.drag_handle,
                            color: Colors.grey, size: 20),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child:
                          Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                    ),
          ],
        ),
      ),
    );
  }
}
