import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/vibes_genre_trending_tracks.dart';
import '../widgets/vibes_genre_albums.dart';
import '../widgets/vibes_genre_playlists.dart';
import '../widgets/vibes_genre_profiles.dart';
import '../widgets/track_tile.dart';
import '../pages/vibes_genre_seeall_page.dart';
import '../widgets/vibes_genre_playlists_tab.dart';
import '../widgets/vibes_genre_albums_tab.dart';
import '../widgets/vibes_genre_trending_tab.dart';

class GenreAllTab extends ConsumerWidget {
  const GenreAllTab({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genreContentProvider(genreId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (content) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // ── Trending ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreSeeAllPage(
                      title: 'Trending',
                      child: GenreTrendingTab(genreId: genreId),
                    ),
                  ),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TrendingTracks(tracks: content.trendingTracks),

          const SizedBox(height: 24),

          // ── Introducing ──────────────────────────────────
          const Text(
            'Introducing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const SizedBox(
            height: 80,
            child: Center(
              child: Text('Coming soon', style: TextStyle(color: Colors.grey)),
            ),
          ),

          const SizedBox(height: 24),

          // ── Playlists ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Playlists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreSeeAllPage(
                      title: 'Playlists',
                      child: GenrePlaylistsTab(genreId: genreId),
                    ),
                  ),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: content.playlists.take(4).length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, i) =>
                GenrePlaylistCard(playlist: content.playlists[i]),
          ),

          const SizedBox(height: 24),

          // ── Albums ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Albums',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreSeeAllPage(
                      title: 'Albums',
                      child: GenreAlbumsTab(genreId: genreId),
                    ),
                  ),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: content.albums.take(4).length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, i) => GenreAlbumCard(album: content.albums[i]),
          ),

          const SizedBox(height: 24),

          // ── Profiles ─────────────────────────────────────
          const Text(
            'Profiles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: content.profiles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  GenreProfileCard(profile: content.profiles[i]),
            ),
          ),

          const SizedBox(height: 24),

          // ── Discover More ────────────────────────────────
          const Text(
            'Discover More',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...content.discoverTracks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TrackTile(track: t),
            ),
          ),
        ],
      ),
    );
  }
}
