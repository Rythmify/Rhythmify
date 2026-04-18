import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/vibes_genre_trending_tracks.dart';
import '../widgets/vibes_genre_albums.dart';
import '../widgets/vibes_genre_playlists.dart';
import '../widgets/vibes_genre_profiles.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../pages/vibes_genre_seeall_page.dart';
import '../widgets/vibes_genre_playlists_tab.dart';
import '../widgets/vibes_genre_albums_tab.dart';
import '../widgets/vibes_genre_trending_tab.dart';
import '../../../search/presentation/widgets/vibes_genre_introducing.dart';

/// The "All" tab on the genre page. Fetches the full [GenreContent] bundle via
/// [genreContentProvider] and renders all sections in a single scrollable list:
/// Trending, Introducing, Playlists, Albums, Profiles, and Discover More Tracks.
///
/// Each section with more items has a "See All" button that pushes a
/// [GenreSeeAllPage] wrapping the relevant independent tab widget.
class GenreAllTab extends ConsumerWidget {
  const GenreAllTab({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genreContentProvider(genreId));

    return async.when(
      loading: () => const Center(
        key: Key('genre_all_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('genre_all_error'), child: Text('Error: $e')),
      data: (content) => ListView(
        key: const Key('genre_all_list'),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // ── Trending ─────────────────────────────────────
          if (content.tracks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  key: const Key('genre_trending_see_all'),
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
            Consumer(
              builder: (context, ref, _) {
                final trendingAsync = ref.watch(genreTracksProvider(genreId));
                return trendingAsync.when(
                  loading: () => const SizedBox(
                    height: 216,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (tracks) => TrendingTracks(
                    key: const Key('genre_trending_tracks'),
                    tracks: tracks.take(6).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],

          // ── Introducing ──────────────────────────────────
          if (content.playlists.isNotEmpty) ...[
            const Text(
              'Introducing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            IntroducingSectionWidget(introducing: content.introducing),

            const SizedBox(height: 24),
          ],

          // ── Playlists (first 4, grid) ────────────────────
          if (content.playlists.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Playlists',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  key: const Key('genre_playlists_see_all'),
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
              key: const Key('genre_playlists_grid'),
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
              itemBuilder: (_, i) => GenrePlaylistCard(
                key: Key('genre_playlist_card_$i'),
                playlist: content.playlists[i],
              ),
            ),

            const SizedBox(height: 24),
          ],
          // ── Albums (first 4, grid) ───────────────────────
          if (content.albums.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Albums',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  key: const Key('genre_albums_see_all'),
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
              key: const Key('genre_albums_grid'),
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
              itemBuilder: (_, i) => GenreAlbumCard(
                key: Key('genre_album_card_$i'),
                album: content.albums[i],
              ),
            ),

            const SizedBox(height: 24),
          ],

          // ── Profiles (horizontal scroll) ─────────────────
          if (content.artists.isNotEmpty) ...[
            const Text(
              'Profiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                key: const Key('genre_profiles_list'),
                scrollDirection: Axis.horizontal,
                itemCount: content.artists.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => GenreProfileCard(
                  key: Key('genre_profile_card_$i'),
                  artist: content.artists[i],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],

          // ── Discover More Tracks ─────────────────────────
          if (content.tracks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover More Tracks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...content.tracks.asMap().entries.map(
              (e) => Padding(
                key: Key('genre_discover_track_${e.key}'),
                padding: const EdgeInsets.only(bottom: 12),
                child: TrackCard(track: e.value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Introducing" section card showing the featured playlist's cover image,
/// name, and description. Handles both network and local asset cover images.
class IntroducingWidget extends StatelessWidget {
  const IntroducingWidget({super.key, required this.introducing});
  final IntroducingSection introducing;

  @override
  Widget build(BuildContext context) {
    final playlist = introducing.playlist;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            // Uses [Image.network] for http URLs, [Image.asset] for local paths.
            child:
                playlist.coverImage.isNotEmpty &&
                    playlist.coverImage.startsWith('http')
                ? Image.network(
                    playlist.coverImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    playlist.coverImage.isNotEmpty
                        ? playlist.coverImage
                        : 'assets/images/track_1.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  playlist.description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
