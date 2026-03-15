import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/feed/presentation/widgets/hot_for_you.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/presentation/widgets/trending_by_genre.dart';

final List<String> genres = [
  'Reggae',
  'Country',
  'Electronic',
  'Indie',
  'Pop',
  'Techno',
  'Jazz',
  'Hip-Hop&Rap',
  'Rock,Metal,Punk',
];

//Trending by genre section
class TrendingByGenre extends StatelessWidget {
  const TrendingByGenre({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: genres.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Trending by Genre", style: AppTheme.titleLarge),
          ),

          SizedBox(height: 10),

          GenreTabBar(),

          SizedBox(height: 20),

          SizedBox(height: 250, child: GenreTabView()),
        ],
      ),
    );
  }
}

//Genre TabBar
class GenreTabBar extends StatelessWidget {
  const GenreTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.all(6),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFF1DB954), width: 1.5),
      ),
      indicatorPadding: const EdgeInsets.symmetric(vertical: 7),
      dividerColor: Colors.transparent,
      labelColor: const Color(0xFF1DB954),
      unselectedLabelColor: const Color(0xFFB0BEB5),
      tabs: genres
          .map(
            (g) => Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF5A6B60),
                    width: 1.5,
                  ),
                ),
                child: Center(child: Text(g)),
              ),
            ),
          )
          .toList(),
    );
  }
}

//TabBar View

class GenreTabView extends ConsumerWidget {
  const GenreTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 110,
      child: Stack(
        children: [
          // green orb background
          FrostedGlassBox(
            child: Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4, -0.4),
                    radius: 0.3,
                    colors: [
                      Color.fromARGB(68, 8, 117, 46),
                      (AppTheme.background),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TabBarView(
            children: genres.map((genre) {
              final asyncTracks = ref.watch(trendingTracksProvider(genre));

              return asyncTracks.when(
                data: (tracks) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: _TrendingHorizontalColumns(tracks: tracks),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

//Horizontal Columns (3 tracks per column)

class _TrendingHorizontalColumns extends ConsumerWidget {
  final List<TrackSummary> tracks;

  const _TrendingHorizontalColumns({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<List<TrackSummary>> chunks = [];

    for (var i = 0; i < tracks.length; i += 3) {
      chunks.add(
        tracks.sublist(i, (i + 3 > tracks.length) ? tracks.length : i + 3),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chunks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, chunkIndex) {
          final chunk = chunks[chunkIndex];

          return Column(
            children: chunk.map((track) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),

                child: SizedBox(
                  width: 330,

                  child: ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        track.artworkUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(
                      track.title,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Text(
                      track.artist,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),

                    trailing: const Icon(Icons.more_horiz, color: Colors.white),

                    onTap: () {
                      final playerState = ref.read(playerStateProvider);
                      final currentTrack = playerState.currentTrack;

                      final isThisTrackLoaded = currentTrack?.id == track.id;

                      if (isThisTrackLoaded) {
                        ref
                            .read(playerStateProvider.notifier)
                            .togglePlayPause();
                      } else {
                        ref.read(playerStateProvider.notifier).loadAndPlayQueue(
                          [track],
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
