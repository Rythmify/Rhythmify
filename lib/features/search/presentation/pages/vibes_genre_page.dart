import 'package:flutter/material.dart';
import '../widgets/vibes_genre_all_tab.dart';
import '../widgets/vibes_genre_trending_tab.dart';
import '../widgets/vibes_genre_playlists_tab.dart';
import '../widgets/vibes_genre_albums_tab.dart';

const _genreImages = {
  'hiphop': 'assets/images/vibes_hiphop.jpeg',
  'electronic': 'assets/images/vibes_electronic.jpeg',
  'pop': 'assets/images/vibes_pop.jpeg',
  'rnb': 'assets/images/vibes_rb.jpeg',
  'party': 'assets/images/vibes_party.jpeg',
  'chill': 'assets/images/vibes_chill.jpeg',
  'techno': 'assets/images/vibes_techno.jpeg',
  'workout': 'assets/images/vibes_workout.jpeg',
};

const _genreTitles = {
  'hiphop': 'Hip Hop & Rap',
  'electronic': 'Electronic',
  'pop': 'Pop',
  'rnb': 'R&B',
  'party': 'Party',
  'chill': 'Chill',
  'techno': 'Techno',
  'workout': 'Workout',
};

class GenrePage extends StatelessWidget {
  const GenrePage({super.key, required this.genre});
  final String genre;

  @override
  Widget build(BuildContext context) {
    final imagePath = _genreImages[genre] ?? 'assets/images/placeholder.png';
    final title = _genreTitles[genre] ?? genre;

    final tabs = [
      GenreAllTab(genreId: genre),
      GenreTrendingTab(genreId: genre),
      GenrePlaylistsTab(genreId: genre),
      GenreAlbumsTab(genreId: genre),
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: const Key('genre_page'),
        body: Column(
          children: [
            // ── Header Image ─────────────────────────────
            Stack(
              key: const Key('genre_header'),
              children: [
                Image.asset(
                  imagePath,
                  key: const Key('genre_header_image'),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(height: 220, color: Colors.grey[900]),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 8,
                  child: IconButton(
                    key: const Key('genre_back_button'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    title,
                    key: const Key('genre_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            ),

            // ── TabBar ───────────────────────────────────
            const TabBar(
              key: Key('genre_tab_bar'),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              dividerColor: Colors.transparent,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontSize: 16),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(key: Key('genre_tab_all'), text: 'All'),
                Tab(key: Key('genre_tab_trending'), text: 'Trending'),
                Tab(key: Key('genre_tab_playlists'), text: 'Playlists'),
                Tab(key: Key('genre_tab_albums'), text: 'Albums'),
              ],
            ),

            // ── TabBarView ───────────────────────────────
            Expanded(
              child: TabBarView(
                key: const Key('genre_tab_view'),
                children: tabs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
