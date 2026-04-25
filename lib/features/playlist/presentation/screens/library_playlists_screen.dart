// lib/features/playlist/presentation/screens/library_playlists_screen.dart

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/time_ago.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

// ── Filter enums ──────────────────────────────────────────────────────────
enum _SortOption { recentlyAdded, firstAdded, recentlyUpdated, playlistName }

// Added: liked filter
enum _FilterOption { all, owned, liked }

// ════════════════════════════════════════════════════════════════════════════
class LibraryPlaylistsScreen extends ConsumerStatefulWidget {
  const LibraryPlaylistsScreen({super.key});

  @override
  ConsumerState<LibraryPlaylistsScreen> createState() =>
      _LibraryPlaylistsScreenState();
}

class _LibraryPlaylistsScreenState
    extends ConsumerState<LibraryPlaylistsScreen> {
  String _searchQuery = '';
  final _SortOption _sort = _SortOption.recentlyAdded;
  _FilterOption _filter = _FilterOption.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (_filter == _FilterOption.liked) {
      ref.read(playlistListProvider.notifier).loadLikedPlaylists();
    } else {
      ref.read(playlistListProvider.notifier).loadPlaylists();
    }
  }

  String _currentUserId() {
    final authState = ref.read(authProvider);
    return authState is AuthAuthenticated ? authState.user.id : '';
  }

  
  List<PlaylistEntity> _applySortAndFilter(List<PlaylistEntity> input) {
    List<PlaylistEntity> result;
 
    if (_filter == _FilterOption.liked) {
      // Liked tab: show everything the backend returned from filter=liked.
      // No type guard — the backend already scoped the results correctly.
      result = List<PlaylistEntity>.from(input);
    } else {
      // All / Created tabs: only show playlists (not albums or stations)
      result = input.where((p) => p.type == PlaylistType.playlist).toList();
    }
 
    if (_filter == _FilterOption.owned) {
      final uid = _currentUserId();
      result = result.where((p) => p.ownerId == uid).toList();
    }
 
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
 
    switch (_sort) {
      case _SortOption.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.recentlyUpdated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.playlistName:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
 
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final filtered = _applySortAndFilter(state.playlists);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 🔶 TOP BACKGROUND
          Positioned(
            top: -60,
            right: -80,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(0.45)
                ..setEntry(0, 1, 0.2),
              child: Column(
                children: List.generate(12, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 320,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF7700).withValues(alpha: 0.8),
                          const Color(0xFFFF7700).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.2),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Search ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: AppTheme.bodyNormal,
                            decoration: InputDecoration(
                              hintText:
                                  'Search ${state.playlists.length} playlists',
                              hintStyle: AppTheme.bodyMedium,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppTheme.textSecondary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: (_sort != _SortOption.recentlyAdded ||
                                  _filter != _FilterOption.all)
                              ? AppTheme.primaryBrand
                              : AppTheme.textSecondary,
                        ),
                        onPressed: () => _showFilterSheet(context),
                      ),
                    ],
                  ),
                ),

                // ── Title ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Playlists', style: AppTheme.headlineLarge),
                  ),
                ),

                // ── Filter chips ─────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'All',
                        active: _filter == _FilterOption.all,
                        onTap: () {
                          setState(() => _filter = _FilterOption.all);
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Created',
                        active: _filter == _FilterOption.owned,
                        onTap: () {
                          setState(() => _filter = _FilterOption.owned);
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Liked',
                        active: _filter == _FilterOption.liked,
                        onTap: () {
                          setState(() => _filter = _FilterOption.liked);
                          _load();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Buttons ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Import not available yet'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.download_outlined,
                            color: AppTheme.textPrimary,
                          ),
                          label: Text('Import', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
                                color: AppTheme.lighterSurface),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCreateSheet(context),
                          icon: const Icon(Icons.add,
                              color: AppTheme.textPrimary),
                          label: Text('Create', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
                                color: AppTheme.lighterSurface),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── List ────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBrand,
                          ),
                        )
                      : filtered.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 140),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final playlist = filtered[index];
                                final isOwner =
                                    playlist.ownerId == _currentUserId();

                                return _PlaylistListTile(
                                  playlist: playlist,
                                  onTap: () => context.push(
                                    '/library/playlists/${playlist.id}',
                                    extra: isOwner,
                                  ),
                                  onMoreTap: () =>
                                      _showOptions(context, playlist, isOwner),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final message = switch (_filter) {
      _FilterOption.liked => 'No liked playlists yet\nLike a mix or playlist to save it here',
      _FilterOption.owned => 'No playlists created yet',
      _FilterOption.all => 'No playlists yet',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter & Sort', style: AppTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Filter', style: AppTheme.labelSmall),
              RadioListTile<_FilterOption>(
                value: _FilterOption.all,
                groupValue: _filter,
                title: Text('All', style: AppTheme.bodyNormal),
                activeColor: AppTheme.primaryBrand,
                onChanged: (v) {
                  setState(() => _filter = v!);
                  _load();
                  Navigator.of(ctx).pop();
                },
              ),
              RadioListTile<_FilterOption>(
                value: _FilterOption.owned,
                groupValue: _filter,
                title: Text('Created by me', style: AppTheme.bodyNormal),
                activeColor: AppTheme.primaryBrand,
                onChanged: (v) {
                  setState(() => _filter = v!);
                  _load();
                  Navigator.of(ctx).pop();
                },
              ),
              RadioListTile<_FilterOption>(
                value: _FilterOption.liked,
                groupValue: _filter,
                title: Text('Liked', style: AppTheme.bodyNormal),
                activeColor: AppTheme.primaryBrand,
                onChanged: (v) {
                  setState(() => _filter = v!);
                  _load();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePlaylistSheet(
        onCreated: (id) => context.push('/library/playlists/$id', extra: true),
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    PlaylistEntity playlist,
    bool isOwner,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PlaylistOptionsSheet(playlistId: playlist.id, isOwner: isOwner),
    );
  }
}

// ── Small filter chip ─────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrand : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
class _PlaylistListTile extends StatelessWidget {
  const _PlaylistListTile({
    required this.playlist,
    required this.onTap,
    required this.onMoreTap,
  });

  final PlaylistEntity playlist;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(playlist: playlist, size: 60, borderRadius: 0),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.name, style: AppTheme.bodyNormal),
                  Text(playlist.ownerName, style: AppTheme.artistTitle),
                  Text(
                    '${playlist.subtitleLine} · ${timeAgo(playlist.createdAt)}',
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}