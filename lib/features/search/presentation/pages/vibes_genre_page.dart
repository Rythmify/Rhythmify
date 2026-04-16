import 'package:flutter/material.dart';
import '../widgets/vibes_genre_all_tab.dart';
import '../widgets/vibes_genre_trending_tab.dart';
import '../widgets/vibes_genre_playlists_tab.dart';
import '../widgets/vibes_genre_albums_tab.dart';

/// Maps genre IDs to their local asset image paths.
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

/// Maps genre IDs to their human-readable display titles.
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

/// The genre/vibes detail page.
///
/// Displays a fixed header image with the genre title overlaid, followed by
/// a full-width [TabBar] with four tabs: All, Trending, Playlists, Albums.
/// Each tab is an independent widget that manages its own provider and data.
///
/// [genre] is the genre ID (e.g. `'hiphop'`) used to resolve the image, title,
/// and passed down to each tab widget for its provider family key.
class GenrePage extends StatelessWidget {
  const GenrePage({
    super.key,
    required this.genreId,
    required this.genreName,
    required this.coverImage, // TODO: use when endpoint adds cover_image
  });

  final String genreId;
  final String genreName;
  final String coverImage;

  @override
  Widget build(BuildContext context) {
    // fallback until cover_image is added to /genres endpoint
    final imagePath = coverImage.isNotEmpty
        ? coverImage
        : 'assets/images/placeholder.png';

    final tabs = [
      GenreAllTab(genreId: genreId),
      GenreTrendingTab(genreId: genreId),
      GenrePlaylistsTab(genreId: genreId),
      GenreAlbumsTab(genreId: genreId),
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: const Key('genre_page'),
        body: Column(
          children: [
            Stack(
              key: const Key('genre_header'),
              children: [
                coverImage.isNotEmpty
                    ? Image.network(
                        imagePath,
                        key: const Key('genre_header_image'),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(height: 220, color: Colors.grey[900]),
                      )
                    : Image.asset(
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
                    genreName, // ← uses passed name directly
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
            const TabBar(
              key: Key('genre_tab_bar'),
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
