import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/presentation/widgets/cast_media_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/entities/track.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../player/domain/entities/queue_state.dart';

class UploadedTracksPage extends ConsumerStatefulWidget {
  final String userId;

  const UploadedTracksPage({super.key, required this.userId});

  @override
  ConsumerState<UploadedTracksPage> createState() => _UploadedTracksPageState();
}

class _UploadedTracksPageState extends ConsumerState<UploadedTracksPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(profileProvider.notifier)
          .loadProfile(userId: widget.userId);
      if (mounted) {
        ref
            .read(profileProvider.notifier)
            .loadUploadedTracks(
              userId: widget.userId,
              refresh: true,
              limit: 20,
            );
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(profileProvider.notifier)
            .loadUploadedTracks(userId: widget.userId);
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
        title: const Text('Uploaded tracks'),
        centerTitle: false,
        leading: IconButton(
          key: const Key('uploaded_tracks_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const Key('uploaded_tracks_cast_button'),
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
    if (state.uploadedTracks.isEmpty && !state.isLoadingUploads) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No uploads yet',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracks you upload will appear here.',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final filtered = _query.isEmpty
        ? state.uploadedTracks
        : state.uploadedTracks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(_query.toLowerCase()) ||
                    t.artist.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return RefreshIndicator(
      color: AppTheme.primaryBrand,
      onRefresh: () async {
        await ref
            .read(profileProvider.notifier)
            .loadProfile(userId: widget.userId);
        await ref
            .read(profileProvider.notifier)
            .loadUploadedTracks(
              userId: widget.userId,
              refresh: true,
              limit: 20,
            );
      },
      child: Column(
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
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search uploads',
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
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  key: const Key('uploaded_tracks_shuffle_button'),
                  icon: const Icon(
                    Icons.shuffle,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    if (filtered.isNotEmpty) {
                      final shuffled = List<Track>.from(filtered)..shuffle();
                      ref
                          .read(queueStateProvider.notifier)
                          .playQueue(
                            tracks: shuffled,
                            initialIndex: 0,
                            context: QueueContext(
                              type: QueueSource.userTracks,
                              targetUserId: widget.userId == 'me'
                                  ? null
                                  : widget.userId,
                            ),
                          );
                    }
                  },
                ),
                FloatingActionButton.small(
                  key: const Key('uploaded_tracks_play_all_fab'),
                  heroTag: 'uploaded_tracks_play',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    if (filtered.isNotEmpty) {
                      ref
                          .read(queueStateProvider.notifier)
                          .playQueue(
                            tracks: filtered,
                            initialIndex: 0,
                            context: QueueContext(
                              type: QueueSource.userTracks,
                              targetUserId: widget.userId == 'me'
                                  ? null
                                  : widget.userId,
                            ),
                          );
                    }
                  },
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return state.isLoadingUploads
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
                  key: Key('upload_item_${filtered[index].id}'),
                  track: filtered[index],
                  onTap: () {
                    ref
                        .read(queueStateProvider.notifier)
                        .playQueue(
                          tracks: filtered,
                          initialIndex: index,
                          context: QueueContext(
                            type: QueueSource.userTracks,
                            targetUserId: widget.userId == 'me'
                                ? null
                                : widget.userId,
                          ),
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
