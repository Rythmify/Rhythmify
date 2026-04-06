import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../../../track/presentation/widgets/track_card.dart';

/// Likes page matching SoundCloud's layout.
///
/// Structure:
/// - Rounded search bar at top
/// - Shuffle + small play FAB action row
/// - [ListView] of track items using the [TrackCard] widget
class LikesPage extends ConsumerStatefulWidget {
  /// The ID of the user whose liked tracks to display.
  ///
  /// Pass `'me'` for the authenticated user's own likes.
  final String userId;

  const LikesPage({super.key, required this.userId});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    // Attach scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(profileProvider.notifier)
            .loadLikedTracks(userId: widget.userId);
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
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your likes'),
        centerTitle: false,
        leading: IconButton(
          key: const Key('likes_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const Key('likes_cast_button'),
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
        ],
      ),
      body: switch (profileState) {
        ProfileLoaded() => _buildList(profileState),
        ProfileLoading() => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildList(ProfileLoaded state) {
    if (state.likedTracks.isEmpty && !state.isLoadingTracks) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No liked tracks yet',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracks you like will appear here.',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Filter tracks based on search query
    final filtered = _query.isEmpty
        ? state.likedTracks
        : state.likedTracks
            .where((t) =>
                t.title.toLowerCase().contains(_query.toLowerCase()) ||
                t.artist.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(21),
            ),
            child: TextField(
              key: const Key('likes_search_text_field'),
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search ${state.likedTracks.length} tracks',
                hintStyle: AppTheme.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: const Icon(
                  Icons.tune,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
              ),
            ),
          ),
        ),

        // ── Action row: shuffle + play ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                key: const Key('likes_add_icon_button'),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                key: const Key('likes_shuffle_icon_button'),
                icon: const Icon(Icons.shuffle, color: AppTheme.textSecondary),
                onPressed: () {},
              ),
              FloatingActionButton.small(
                key: const Key('likes_play_all_fab'),
                heroTag: 'likes_play',
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
            key: const Key('likes_list_view'),
            controller: _scrollController,
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              // Pagination footer
              if (index == filtered.length) {
                return state.isLoadingTracks
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBrand,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox(height: 120);
              }

              return TrackCard(
                key: Key('likes_track_${filtered[index].id}'),
                track: filtered[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
