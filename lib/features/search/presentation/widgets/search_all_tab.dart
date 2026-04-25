import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/search/presentation/widgets/search_albums_tab.dart';
import 'package:rythmify/features/track/presentation/widgets/track_card.dart';
import '../providers/search_providers.dart';
import '../widgets/track_tile.dart';
import '../widgets/search_profiles_tab.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/utils/formatters.dart';
import '../pages/search_seeall_page.dart';
import '../widgets/search_tracks_tab.dart';
import '../widgets/search_playlists_tab.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/top_result.dart';

/// The "All" tab in search results. Shows a mixed-content summary page with:
/// Top Result, Tracks (first 3), Profiles (first 3), Playlists (first 3),
/// Albums (first 3), and a "More Results" section for remaining tracks.
class AllTab extends ConsumerWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(
        key: Key('all_tab_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('all_tab_error'), child: Text('Error: $e')),
      data: (data) => ListView(
        key: const Key('all_tab_list'),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
        children: [
          // ── Top Result ──────────────────────────────────────
          const _SectionTitle('Top Result'),
          const SizedBox(height: 12),
          if (data.topResult != null)
            _TopResultCard(topResult: data.topResult!)
          else
            const _EmptySection(label: 'No top result'),

          const SizedBox(height: 24),

          // ── Tracks ──────────────────────────────────────────
          if (data.tracks.isNotEmpty) ...[
            _SectionHeader(
              title: 'Tracks',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchSeeAllPage(
                    title: 'Tracks',
                    child: TracksTab(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (data.tracks.isNotEmpty)
              _TracksSection(tracks: data.tracks)
            else
              const _EmptySection(label: 'No tracks found'),

            const SizedBox(height: 24),
          ],
          // ── Profiles ────────────────────────────────────────
          if (data.profiles.isNotEmpty) ...[
            _SectionHeader(
              title: 'Profiles',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchSeeAllPage(
                    title: 'Profiles',
                    child: ProfilesTab(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...data.profiles
                .take(1)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    key: Key('all_tab_profile_${e.key}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SearchProfileCard(profile: e.value),
                  ),
                ),
            const SizedBox(height: 24),
          ],

          // ── Playlists ───────────────────────────────────────
          if (data.playlists.isNotEmpty) ...[
            _SectionHeader(
              title: 'Playlists',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchSeeAllPage(
                    title: 'Playlists',
                    child: PlaylistsTab(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...data.playlists
                .take(3)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    key: Key('all_tab_playlist_${e.key}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PlaylistRow(playlist: e.value),
                  ),
                ),
            const SizedBox(height: 24),
          ],

          // ── Albums ──────────────────────────────────────────
          if (data.albums.isNotEmpty) ...[
            _SectionHeader(
              title: 'Albums',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchSeeAllPage(
                    title: 'Albums',
                    child: AlbumsTab(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...data.albums
                .take(3)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    key: Key('all_tab_album_${e.key}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AlbumRow(album: e.value),
                  ),
                ),
          ],

          // ── More Results — tracks beyond the first 3 ─────────────────────────
          if (data.tracks.length > 3) ...[
            const SizedBox(height: 24),
            const _SectionTitle('More Results'),
            const SizedBox(height: 12),
            ...data.tracks
                .sublist(3)
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    key: Key('all_tab_more_track_${e.key}'),
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

// ── Playlist row ─────────────────────────────────────────────────────────────

/// A single playlist row showing artwork, title, track count, and formatted duration.
/// Accepts a raw [Map<String, String>] until a teammate-owned Playlist entity is available.
class _PlaylistRow extends StatelessWidget {
  final Map<String, String> playlist;
  const _PlaylistRow({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        context.push('/playlist/${playlist['id']}', extra: false);
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          playlist['artworkUrl']!,
          key: Key('all_tab_playlist_artwork_${playlist['id']}'),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Container(width: 50, height: 50, color: Colors.grey[800]),
        ),
      ),
      title: Text(
        playlist['title']!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // Duration is formatted from raw seconds via [Formatters.formatPlaylistDuration].
      subtitle: Text(
        'Playlist · ${playlist['trackCount']} tracks · ${Formatters.formatPlaylistDuration(int.parse(playlist['totalSeconds'] ?? '0'))}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert),
    );
  }
}

// ── Album row ────────────────────────────────────────────────────────────────

/// A single album row showing artwork, title, artist, year, and type.
/// Accepts a raw [Map<String, String>] until a teammate-owned Album entity is available.
class _AlbumRow extends StatelessWidget {
  final Map<String, String> album;
  const _AlbumRow({required this.album});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        context.push('/playlist/${album['id']}', extra: false);
      },
      isThreeLine: true,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          album['artworkUrl']!,
          key: Key('all_tab_album_artwork_${album['id']}'),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Container(width: 50, height: 50, color: Colors.grey[800]),
        ),
      ),
      title: Text(
        album['title']!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            album['artist']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          // Shows release year and album type (e.g. "2020 · Album").
          Text(
            '${album['year']} · ${album['type']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

/// Displays the top search result as a prominent track card with artwork,
/// title, artist, and formatted duration.
class _TopResultCard extends StatelessWidget {
  const _TopResultCard({required this.topResult});
  final TopResult topResult;

  @override
  Widget build(BuildContext context) {
    return switch (topResult) {
      TopResultTrack(:final track) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            track.artworkUrl.isNotEmpty ? track.artworkUrl : '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(width: 50, height: 50, color: Colors.grey[800]),
          ),
        ),
        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(track.artist, style: TextStyle(color: Colors.grey[400])),
        trailing: const Icon(Icons.more_vert),
      ),

      TopResultUser(:final profile) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          profile.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Profile', style: TextStyle(color: Colors.grey[400])),
        trailing: const Icon(Icons.more_vert),
        onTap: () => context.push('/profile/${profile.id}'),
      ),

      TopResultPlaylist(:final playlist) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            playlist['artworkUrl'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(width: 50, height: 50, color: Colors.grey[800]),
          ),
        ),
        title: Text(
          playlist['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Playlist · ${playlist['trackCount']} tracks',
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: const Icon(Icons.more_vert),
        onTap: () => context.push('/playlist/${playlist['id']}', extra: false),
      ),

      TopResultAlbum(:final album) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            album['artworkUrl'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(width: 50, height: 50, color: Colors.grey[800]),
          ),
        ),
        title: Text(
          album['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${album['year']} · ${album['type']}',
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: const Icon(Icons.more_vert),
        onTap: () => context.push('/playlist/${album['id']}', extra: false),
      ),
    };
  }
}

/// Shows up to the first 3 tracks from the results as [TrackTile] rows.
class _TracksSection extends StatelessWidget {
  const _TracksSection({required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('all_tab_tracks_section'),
      children: tracks.take(3).toList().asMap().entries.map((e) {
        return Padding(
          key: Key('all_tab_track_${e.key}'),
          padding: const EdgeInsets.only(bottom: 12),
          child: TrackCard(track: e.value),
        );
      }).toList(),
    );
  }
}

/// A bold section header label used throughout the All tab.
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
    );
  }
}

/// A muted placeholder shown when a content section has no results.
class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(label, style: TextStyle(color: Colors.grey[500])),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: const Text('See all'),
        ),
      ],
    );
  }
}
