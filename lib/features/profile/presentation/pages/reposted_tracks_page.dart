import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/presentation/widgets/cast_media_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../../../track/presentation/widgets/track_card.dart';

class RepostedTracksPage extends ConsumerStatefulWidget {
  final String userId;

  const RepostedTracksPage({super.key, required this.userId});

  @override
  ConsumerState<RepostedTracksPage> createState() => _RepostedTracksPageState();
}

class _RepostedTracksPageState extends ConsumerState<RepostedTracksPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    // Trigger initial load after build phase
    Future.microtask(
      () => ref
          .read(profileProvider.notifier)
          .loadProfile(userId: widget.userId),
    );

    // Attach scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(profileProvider.notifier)
            .loadRepostedTracks(userId: widget.userId);
      }
    });

    // Ensure we load full list (if only preview was loaded)
    Future.microtask(() {
      final s = ref.read(profileProvider);
      if (s is ProfileLoaded && s.repostedTracks.length <= 3) {
        ref.read(profileProvider.notifier).loadRepostedTracks(
              userId: widget.userId,
              refresh: true,
              limit: 20,
            );
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
        title: const Text('Reposted tracks'),
        centerTitle: false,
        leading: IconButton(
          key: const Key('reposted_tracks_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const Key('reposted_tracks_cast_button'),
            icon: const Icon(Icons.cast),
            onPressed: () => showCastMediaSheet(context, ref),
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
    if (state.repostedTracks.isEmpty && !state.isLoadingReposts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No reposts yet',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracks you repost will appear here.',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final filtered = _query.isEmpty
        ? state.repostedTracks
        : state.repostedTracks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(_query.toLowerCase()) ||
                    t.artist.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(21),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search reposts',
                hintStyle: AppTheme.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == filtered.length) {
                return state.isLoadingReposts
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
                key: Key('repost_item_${filtered[index].id}'),
                track: filtered[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
