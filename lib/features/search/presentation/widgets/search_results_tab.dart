import 'package:flutter/material.dart';
import '../widgets/search_albums_tab.dart';
import '../widgets/search_all_tab.dart';
import '../widgets/search_playlists_tab.dart';
import '../widgets/search_tracks_tab.dart';
import '../widgets/search_profiles_tab.dart';

class SearchResultsTabs extends StatelessWidget {
  const SearchResultsTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            key: Key('search_tab_bar'),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            dividerColor: Colors.transparent,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 16),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(key: Key('search_tab_all'), text: 'All'),
              Tab(key: Key('search_tab_tracks'), text: 'Tracks'),
              Tab(key: Key('search_tab_profiles'), text: 'Profiles'),
              Tab(key: Key('search_tab_playlists'), text: 'Playlists'),
              Tab(key: Key('search_tab_albums'), text: 'Albums'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              key: Key('search_tab_view'),
              children: [
                AllTab(),
                TracksTab(),
                ProfilesTab(),
                PlaylistsTab(),
                AlbumsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
