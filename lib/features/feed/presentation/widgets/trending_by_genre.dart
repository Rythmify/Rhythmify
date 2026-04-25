import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/genre_tab.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/providers/queue_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:ui';
import '../providers/home_providers.dart';
import '../../../track/presentation/widgets/bottom_sheets/track_options_modal.dart';

final List<Color> genreColors = [
  const Color.fromARGB(255, 28, 197, 22),
  Colors.pink,
  Colors.purple,
  const Color.fromARGB(255, 4, 144, 208),
  Colors.pink,
  const Color.fromARGB(255, 19, 45, 195),
  const Color.fromARGB(255, 187, 34, 149),
  const Color.fromARGB(255, 197, 18, 6),
  const Color.fromARGB(255, 19, 45, 195),
];

class TrendingByGenre extends ConsumerStatefulWidget {
  const TrendingByGenre({super.key});

  @override
  ConsumerState<TrendingByGenre> createState() => _TrendingByGenreState();
}

class _TrendingByGenreState extends ConsumerState<TrendingByGenre>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<GenreTab>? _genres;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initTabController(List<GenreTab> genres) {
    if (_genres == genres) return;
    _tabController?.dispose();
    _genres = genres;
    _tabController = TabController(length: genres.length, vsync: this);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final asyncHome = ref.watch(homeDataProvider);

    return Column(
      key: const Key('trending_by_genre_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 16),
          child: Text("Trending by Genre", style: AppTheme.homeTitle),
        ),
        asyncHome.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (homeData) {
            final genres = homeData.trendingByGenre.genres;
            _initTabController(genres);

            final tabController = _tabController;
            if (tabController == null) return const SizedBox.shrink();

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, _) {
                final selectedIndex = tabController.index;
                final currentColor =
                    genreColors[selectedIndex % genreColors.length];

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: AppTheme.background),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.4, -0.3),
                            radius: 0.49,
                            colors: [
                              currentColor.withValues(alpha: 0.35),
                              currentColor.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.2, -0.1),
                            radius: 0.5,
                            colors: [
                              currentColor.withValues(alpha: 0.28),
                              currentColor.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 22,
                          sigmaY: 22,
                          tileMode: TileMode.decal,
                        ),
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GenreTabBar(
                                tabController: tabController,
                                genres: genres,
                              ),
                              SizedBox(
                                height: 250,
                                child: GenreTabView(
                                  tabController: tabController,
                                  genres: genres,
                                  initialTracks: homeData
                                      .trendingByGenre
                                      .initialTab
                                      .tracks,
                                  initialGenreId: homeData
                                      .trendingByGenre
                                      .initialTab
                                      .genreId,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class GenreTabBar extends StatelessWidget {
  final TabController tabController;
  final List<GenreTab> genres;

  const GenreTabBar({
    super.key,
    required this.tabController,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          key: const Key('genre_tab_bar'),
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicator: const BoxDecoration(),
          tabs: List.generate(genres.length, (index) {
            final isSelected = tabController.index == index;
            final color = genreColors[index % genreColors.length];

            return Tab(
              key: Key(
                'trending_by_genre_tab_${genres[index].genreName.toLowerCase().replaceAll(' ', '_')}',
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.semiWhite,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  genres[index].genreName,
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

class GenreTabView extends ConsumerWidget {
  final TabController tabController;
  final List<GenreTab> genres;
  final List<Track> initialTracks;
  final String initialGenreId;

  const GenreTabView({
    super.key,
    required this.tabController,
    required this.genres,
    required this.initialTracks,
    required this.initialGenreId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      key: const Key('genre_tab_view'),
      controller: tabController,
      children: genres.map((genre) {
        // Use pre-loaded tracks for the initial tab, fetch for others
        if (genre.genreId == initialGenreId) {
          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _TrendingHorizontalColumns(tracks: initialTracks),
          );
        }

        final asyncTracks = ref.watch(trendingByGenreProvider(genre.genreId));

        return asyncTracks.when(
          data: (genreTabTracks) => Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _TrendingHorizontalColumns(tracks: genreTabTracks.tracks),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              key: Key(
                'trending_by_genre_error_text_${genre.genreName.toLowerCase().replaceAll(' ', '_')}',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TrendingHorizontalColumns extends ConsumerWidget {
  final List<Track> tracks;

  const _TrendingHorizontalColumns({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<List<Track>> chunks = [];
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
              return SizedBox(
                width: 380,
                child: ListTile(
                  key: Key('item_${track.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child:
                        track.coverImage != null &&
                            track.coverImage!.startsWith('http')
                        ? Image.network(
                            track.coverImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            track.coverImage!,
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
                  trailing: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TrackOptionsModal(track: track),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    final playerState = ref.read(playerStateProvider);
                    final isThisTrackLoaded =
                        playerState.currentTrack?.id == track.id;

                    if (isThisTrackLoaded) {
                      ref.read(playerStateProvider.notifier).togglePlayPause();
                    } else {
                      ref
                          .read(queueStateProvider.notifier)
                          .playQueue(
                            tracks: tracks,
                            initialIndex: tracks.indexOf(track),
                          );
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
