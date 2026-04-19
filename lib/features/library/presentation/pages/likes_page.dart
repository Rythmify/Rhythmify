import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';

/// Your Likes page matching SoundCloud's layout.
///
/// Layout sections (top → bottom):
/// 1. [AppBar] — back arrow, search bar, filter icon, cast icon.
/// 2. Header area — "Your likes" title, shuffle + play FAB row.
/// 3. [ListView] of liked [TrackCard] tiles, or an empty state.
class LibraryLikesPage extends ConsumerStatefulWidget {
  const LibraryLikesPage({super.key});

  @override
  ConsumerState<LibraryLikesPage> createState() => _LibraryLikesPageState();
}

class _LibraryLikesPageState extends ConsumerState<LibraryLikesPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(likesProvider.notifier).load();
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
    final state = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('library_likes_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarItems),
          onPressed: () => context.pop(),
        ),
        title: _SearchBar(
          key: const Key('library_likes_search_bar'),
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          IconButton(
            key: const Key('library_likes_filter_button'),
            icon: const Icon(Icons.tune, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('library_likes_cast_button'),
            icon: const Icon(Icons.cast, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(likesProvider.notifier).load(refresh: true),
        child: state.isLoading && state.tracks.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              )
            : _buildScrollView(context, state),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, LikesState state) {
    final filtered = _query.isEmpty
        ? state.tracks
        : state.tracks
              .where(
                (t) => t.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return CustomScrollView(
      key: const Key('library_likes_scroll_view'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _LikesHeader(onShuffle: () {}, onPlay: () {}),
        ),

        if (state.tracks.isEmpty && !state.isLoading)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyLikes())
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
                return TrackCard(track: filtered[index].track);
              },
            ),
          ),
        ],
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
          hintText: 'Search in your likes',
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

class _LikesHeader extends StatelessWidget {
  const _LikesHeader({required this.onShuffle, required this.onPlay});

  final VoidCallback onShuffle;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text('Your likes', style: AppTheme.headlineLarge)),
          _CircleIconButton(
            key: const Key('library_likes_shuffle_button'),
            icon: Icons.shuffle,
            onTap: onShuffle,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            key: const Key('library_likes_play_button'),
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

class _EmptyLikes extends StatelessWidget {
  const _EmptyLikes();

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
                colors: [Color(0xFFE94E1B), Color(0xFFF27121)],
              ),
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Colors.white54,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tracks liked yet',
            style: AppTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tracks you like will show up here',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
