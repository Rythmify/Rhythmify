import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../../../playlist/domain/entities/playlist_entity.dart';

enum PlaylistPageType { playlists, albums }

class UserPlaylistsPage extends ConsumerStatefulWidget {
  final String userId;
  final PlaylistPageType type;

  const UserPlaylistsPage({
    super.key,
    required this.userId,
    this.type = PlaylistPageType.playlists,
  });

  @override
  ConsumerState<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends ConsumerState<UserPlaylistsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = widget.userId == 'me'
          ? ref.read(ownProfileProvider.notifier)
          : ref.read(publicProfileProvider(widget.userId).notifier);

      notifier.loadPlaylists(userId: widget.userId, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = widget.userId == 'me'
        ? ref.watch(ownProfileProvider)
        : ref.watch(publicProfileProvider(widget.userId));

    final title = widget.type == PlaylistPageType.albums
        ? 'Albums'
        : 'Playlists';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (profileState) {
        ProfileLoaded(
          :final playlists,
          :final albums,
          :final isLoadingPlaylists,
        ) =>
          _buildGrid(
            context,
            widget.type == PlaylistPageType.albums ? albums : playlists,
            isLoadingPlaylists,
          ),
        ProfileLoading() => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<PlaylistEntity> playlists,
    bool isLoading,
  ) {
    if (playlists.isEmpty && !isLoading) {
      return Center(
        child: Text('No playlists yet', style: AppTheme.bodyMedium),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryBrand,
      onRefresh: () async {
        final notifier = widget.userId == 'me'
            ? ref.read(ownProfileProvider.notifier)
            : ref.read(publicProfileProvider(widget.userId).notifier);
        await notifier.loadPlaylists(userId: widget.userId, refresh: true);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: playlists.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return _PlaylistCard(playlist: playlist);
        },
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistEntity playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/playlist/${playlist.id}', extra: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child:
                    (playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: playlist.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _placeholder(),
                        errorWidget: (context, url, error) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: AppTheme.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            playlist.ownerName.isNotEmpty ? playlist.ownerName : 'You',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.surface,
    child: const Center(
      child: Icon(Icons.music_note, color: AppTheme.textSecondary, size: 40),
    ),
  );
}
