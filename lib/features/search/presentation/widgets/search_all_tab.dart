import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../widgets/track_tile.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/utils/formatters.dart';

class AllTab extends ConsumerWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
        children: [
          const _SectionTitle('Top Result'),
          const SizedBox(height: 12),
          if (data.tracks.isNotEmpty)
            _TopResultCard(track: data.tracks.first)
          else
            const _EmptySection(label: 'No top result'),

          const SizedBox(height: 24),

          const _SectionTitle('Tracks'),
          const SizedBox(height: 12),
          if (data.tracks.isNotEmpty)
            _TracksSection(tracks: data.tracks)
          else
            const _EmptySection(label: 'No tracks found'),

          const SizedBox(height: 24),

          const _SectionTitle('Playlists'),
          const SizedBox(height: 12),
          const _EmptySection(label: 'No playlists found'),

          const SizedBox(height: 24),

          const _SectionTitle('More Results'),
          const SizedBox(height: 12),
          const _EmptySection(label: 'No more results'),
        ],
      ),
    );
  }
}

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          track.artworkUrl.isNotEmpty
              ? track.artworkUrl
              : 'assets/images/placeholder.png',
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
      onTap: () {
        // later → trigger player
      },
    );
  }
}

class _TracksSection extends StatelessWidget {
  const _TracksSection({required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tracks.take(3).map((t) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TrackTile(track: t),
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
