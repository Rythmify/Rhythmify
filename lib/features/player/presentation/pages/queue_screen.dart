import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../providers/queue_provider.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Call fetch more if backend was available
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(queueStateProvider);
    final upcomingTracks = queueState.upcomingTracks;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Up Next',
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
      body: upcomingTracks.isEmpty
          ? const Center(
              child: Text(
                'Queue is empty',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ReorderableListView.builder(
              key: const Key('player_queue_listview'),
              scrollController: _scrollController,
              itemCount: upcomingTracks.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(queueStateProvider.notifier)
                    .reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final track = upcomingTracks[index];
                return Padding(
                  key: ValueKey(track.id), // Important for ReorderableListView
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_handle, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          key: Key(
                            'player_queue_track_gesture_detector_${track.id}',
                          ),
                          onTap: () {
                            ref
                                .read(queueStateProvider.notifier)
                                .playFromQueue(index);
                          },
                          child: IgnorePointer(
                            child: TrackCard(
                              key: Key('player_queue_track_card_${track.id}'),
                              track: track,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
