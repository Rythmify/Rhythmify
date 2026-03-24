import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/track_list_tile.dart';

class LikesPage extends ConsumerStatefulWidget {
  final String userId;

  const LikesPage({super.key, required this.userId});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
