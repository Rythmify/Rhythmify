import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../widgets/track_tile.dart';
import '../widgets/search_profiles_tab.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/utils/formatters.dart';

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
          if (data.tracks.isNotEmpty)
            _TopResultCard(track: data.tracks.first)
          else
            const _EmptySection(label: 'No top result'),

          const SizedBox(height: 24),

          // ── Tracks ──────────────────────────────────────────
          const _SectionTitle('Tracks'),
          const SizedBox(height: 12),
          if (data.tracks.isNotEmpty)
            _TracksSection(tracks: data.tracks)
          else
            const _EmptySection(label: 'No tracks found'),

          const SizedBox(height: 24),

          // ── Profiles ────────────────────────────────────────
          if (data.profiles.isNotEmpty) ...[
            const _SectionTitle('Profiles'),
            const SizedBox(height: 12),
            ...data.profiles
                .take(3)
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
            const _SectionTitle('Playlists'),
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
            const _SectionTitle('Albums'),
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

          // ── More Results ─────────────────────────────────────
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
                    child: TrackTile(track: e.value),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

// ── Playlist row ─────────────────────────────────────────────────────────────

class _PlaylistRow extends StatelessWidget {
  final Map<String, String> playlist;
  const _PlaylistRow({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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

class _AlbumRow extends StatelessWidget {
  final Map<String, String> album;
  const _AlbumRow({required this.album});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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

// ── Existing private widgets ──────────────────────────────────────────────────

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('all_tab_top_result'),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          track.artworkUrl.isNotEmpty
              ? track.artworkUrl
              : 'assets/images/placeholder.png',
          key: const Key('all_tab_top_result_artwork'),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Container(width: 50, height: 50, color: Colors.grey[800]),
        ),
      ),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatDuration(track.duration),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert),
      onTap: () {},
    );
  }
}

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
          child: TrackTile(track: e.value),
        );
      }).toList(),
    );
  }
}

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
