import 'package:flutter/material.dart';
import '../widgets/vibes_genre_all_tab.dart';
import '../widgets/vibes_genre_trending_tab.dart';
import '../widgets/vibes_genre_playlists_tab.dart';
import '../widgets/vibes_genre_albums_tab.dart';

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
    required this.coverImage,
  });

  final String genreId;
  final String genreName;
  final String coverImage;

  @override
  Widget build(BuildContext context) {
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
                Image.asset(
                  coverImage.isNotEmpty
                      ? coverImage
                      : 'assets/images/placeholder.png',
                  key: const Key('genre_header_image'),
                  width: double.infinity,
                  height: 200,
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    genreName, //  uses passed name directly
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
