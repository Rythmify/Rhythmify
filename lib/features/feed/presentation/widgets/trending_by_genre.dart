import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/theme/app_theme.dart';

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

final List<Color> genreColors = [
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.blue,
  Colors.pink,
  Colors.teal,
  Colors.amber,
  Colors.red,
  Colors.indigo,
];

//Trending by genre section
class TrendingByGenre extends StatefulWidget {
  const TrendingByGenre({super.key});

  @override
  State<TrendingByGenre> createState() => _TrendingByGenreState();
}

class _TrendingByGenreState extends State<TrendingByGenre>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: genres.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Trending by Genre", style: AppTheme.titleLarge),
        ),
        SizedBox(height: 10),

        GenreTabBar(tabController: _tabController),

        SizedBox(height: 20),

        SizedBox(
          height: 250,
          child: GenreTabView(tabController: _tabController),
        ),
      ],
    );
  }
}

//Genre TabBar
class GenreTabBar extends StatelessWidget {
  final TabController tabController;

  const GenreTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),

          indicator: const BoxDecoration(),

          tabs: List.generate(genres.length, (index) {
            final isSelected = tabController.index == index;
            final color = genreColors[index];

            return Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : const Color(0xFF5A6B60), // grey when unselected
                    width: 1.5,
                  ),
                ),
                child: Text(
                  genres[index],
                  style: TextStyle(
                    color: isSelected ? color : const Color(0xFFB0BEB5),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
//TabBar View

class GenreTabView extends ConsumerWidget {
  final TabController tabController;

  const GenreTabView({super.key, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 110,
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          final selectedIndex = tabController.index;
          final currentColor = genreColors[selectedIndex];

          return Stack(
            children: [
              //Dynamic orb background
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.1),
                    radius: 0.4,
                    colors: [
                      currentColor.withValues(alpha: 0.5),
                      AppTheme.background,
                    ],
                  ),
                ),
              ),

              // TabBarView
              TabBarView(
                controller: tabController,
                children: genres.map((genre) {
                  final asyncTracks = ref.watch(trendingTracksProvider(genre));

                  return asyncTracks.when(
                    data: (tracks) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: _TrendingHorizontalColumns(tracks: tracks),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                }).toList(),
              ),
            ],
          );
        },
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
