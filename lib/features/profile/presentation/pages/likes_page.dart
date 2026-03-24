import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/track_list_tile.dart';

/// A dedicated page showing the full paginated list of tracks liked by a user.
///
/// Accessible via:
/// - [LibraryScreen] "Your likes" tile → `/profile/me/likes`
/// - GoRouter route `/profile/:userId/likes`
///
/// ### Loading
///
/// Relies on [profileProvider] already being in [ProfileLoaded] state
/// (loaded by [PublicProfilePage] or [LibraryScreen] beforehand).
/// Does NOT call [ProfileNotifier.loadProfile] itself — the liked tracks
/// are already in [ProfileLoaded.likedTracks].
///
/// ### Pagination
///
/// Attaches a scroll listener to [_scrollController]. When within 200px of
/// the bottom, calls [ProfileNotifier.loadLikedTracks] to fetch the next page.
/// A [CircularProgressIndicator] is rendered at the bottom of the list
/// while [ProfileLoaded.isLoadingTracks] is `true`.
///
/// ### Empty state
///
/// Renders a centered message when [ProfileLoaded.likedTracks] is empty
/// and [ProfileLoaded.isLoadingTracks] is `false`.
class LikesPage extends ConsumerStatefulWidget {
  /// The ID of the user whose liked tracks to display.
  ///
  /// Pass `'me'` for the authenticated user's own likes.
  final String userId;

  /// Creates a [LikesPage] for the user with [userId].
  const LikesPage({super.key, required this.userId});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  final _scrollController = ScrollController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Likes'),
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

  /// Builds the scrollable liked-tracks list or the empty state.
  ///
  /// The list has [ProfileLoaded.likedTracks.length + 1] items: the
  /// extra item at the end renders either the pagination spinner or
  /// an empty [SizedBox] depending on [ProfileLoaded.isLoadingTracks].
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

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.likedTracks.length + 1,
      itemBuilder: (context, index) {
        // Pagination footer
        if (index == state.likedTracks.length) {
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
              : const SizedBox.shrink();
        }

        return TrackListTile(
          key: Key('item_${state.likedTracks[index].id}'),
          track: state.likedTracks[index],
        );
      },
    );
  }
}
