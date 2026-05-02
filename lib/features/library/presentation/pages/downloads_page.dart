import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/downloads_provider.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';

/// Your Downloads page matching SoundCloud's layout.
///
/// Layout sections (top → bottom):
/// 1. [AppBar] — back arrow, search bar, filter icon, cast icon.
/// 2. Header area — "Downloads" title, shuffle + play FAB row.
/// 3. [ListView] of [TrackCard] tiles, or an empty state when
///    [DownloadsState.tracks] is empty.
class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(downloadsProvider.notifier).load();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('downloads_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarItems),
          onPressed: () => context.pop(),
        ),
        title: _SearchBar(
          key: const Key('downloads_search_bar'),
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          IconButton(
            key: const Key('downloads_filter_button'),
            icon: const Icon(Icons.tune, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('downloads_cast_button'),
            icon: const Icon(Icons.cast, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(downloadsProvider.notifier).load(),
        child: state.isLoading && state.tracks.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              )
            : state.error != null && state.tracks.isEmpty
            ? _ErrorState(
                error: state.error!,
                onRetry: () => ref.read(downloadsProvider.notifier).load(),
              )
            : _buildScrollView(context, state),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, DownloadsState state) {
    final filtered = _query.isEmpty
        ? state.tracks
        : state.tracks
              .where(
                (t) => t.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    final filteredTracks = filtered.map((e) => e.track).toList();

    void playAt(int index) {
      if (filteredTracks.isEmpty) return;
      ref
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: filteredTracks,
            initialIndex: index,
            context: const QueueContext(type: QueueSource.downloads),
          );
    }

    return CustomScrollView(
      key: const Key('downloads_scroll_view'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _DownloadsHeader(
            onShuffle: () {
              if (filteredTracks.isNotEmpty) {
                final shuffled = List<Track>.from(filteredTracks)..shuffle();
                ref
                    .read(queueStateProvider.notifier)
                    .playQueue(
                      tracks: shuffled,
                      initialIndex: 0,
                      context: const QueueContext(type: QueueSource.downloads),
                    );
              }
            },
            onPlay: () => playAt(0),
          ),
        ),

        // Active Downloads Section
        if (state.downloadingProgress.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Downloads',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryBrand,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...state.downloadingProgress.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.downloading,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Track ID: ${entry.key}', // Ideally we'd have the track title here
                                  style: AppTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: entry.value,
                                  backgroundColor: AppTheme.surface,
                                  color: AppTheme.primaryBrand,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(entry.value * 100).toInt()}%',
                            style: AppTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: AppTheme.surface),
                ],
              ),
            ),
          ),

        if (state.tracks.isEmpty && state.downloadingProgress.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: const _EmptyDownloads(),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 120),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return TrackCard(
                  key: Key('downloads_item_${filteredTracks[index].id}_$index'),
                  track: filteredTracks[index],
                  onTap: () => playAt(index),
                  showOptions: false,
                  showStats: false,
                );
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          hintText: 'Search in downloads',
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
}

class _DownloadsHeader extends StatelessWidget {
  const _DownloadsHeader({required this.onShuffle, required this.onPlay});

  final VoidCallback onShuffle;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Downloads',
                  style: AppTheme.headlineLarge.copyWith(height: 1),
                ),
              ),
              _CircleIconButton(
                key: const Key('downloads_shuffle_button'),
                icon: Icons.shuffle,
                onTap: onShuffle,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                key: const Key('downloads_play_button'),
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
          const SizedBox(height: 14),
          _StatChip(
            key: const Key('downloads_count_chip'),
            icon: Icons.download_done_rounded,
            iconColor: AppTheme.primaryBrand,
            label: 'Offline access enabled',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(icon, color: AppTheme.appBarItems, size: 20),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 24),
          Text(
            'Failed to load downloads',
            style: AppTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrand,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004D40), Color(0xFF00251A)],
              ),
            ),
            child: const Icon(
              Icons.download_for_offline_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No downloads yet',
            key: const Key('downloads_empty_headline_text'),
            style: AppTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tracks you download for offline listening will show up here',
            key: const Key('downloads_empty_body_text'),
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
