import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/queue_provider.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/entities/top_result.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_album.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_artists.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_info.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_playlist.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_playlist.dart';
import 'package:rythmify/features/search/presentation/pages/search_screen.dart';
import 'package:rythmify/features/search/presentation/pages/search_seeall_page.dart';
import 'package:rythmify/features/search/presentation/pages/vibes_genre_page.dart';
import 'package:rythmify/features/search/presentation/pages/vibes_genre_seeall_page.dart';
import 'package:rythmify/features/search/presentation/providers/search_providers.dart';
import 'package:rythmify/features/search/presentation/providers/vibes_genre_providers.dart';
import 'package:rythmify/features/search/presentation/providers/vibes_providers.dart';
import 'package:rythmify/features/search/presentation/widgets/search_albums_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/search_all_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/search_bar.dart';
import 'package:rythmify/features/search/presentation/widgets/search_playlists_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/search_profiles_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/search_results_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/search_suggestions_list.dart';
import 'package:rythmify/features/search/presentation/widgets/search_tracks_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/track_tile.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_albums.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_albums_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_all_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_all_tracks_list.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_introducing.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_playlists.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_playlists_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_profiles.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_trending_tab.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_trending_tracks.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_grid.dart';

class FakePlayerNotifier extends PlayerNotifier {
  @override
  AppPlayerState build() => const AppPlayerState();

  @override
  Future<void> loadAndPlayQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {}

  @override
  void togglePlayPause() {}
}

class FakeQueueNotifier extends QueueNotifier {
  @override
  AppQueueState build() => const AppQueueState();

  @override
  Future<void> playQueue({
    required List<Track> tracks,
    required int initialIndex,
    QueueContext? context,
  }) async {}
}

class FakeLoadedPlayerNotifier extends PlayerNotifier {
  @override
  AppPlayerState build() => AppPlayerState(currentTrack: _track());

  @override
  void togglePlayPause() {}
}

class FakePlayingPlayerNotifier extends PlayerNotifier {
  @override
  AppPlayerState build() =>
      AppPlayerState(currentTrack: _track(), status: PlayerStatus.playing);

  @override
  Future<void> loadAndPlayQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {}

  @override
  void togglePlayPause() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('search presentation widgets', () {
    testWidgets('SearchBarWidget updates, submits, syncs, and clears query', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SearchBarWidget()));

      await tester.enterText(find.byKey(const Key('search_bar_field')), 'jazz');
      await tester.pump();

      expect(find.byKey(const Key('search_bar_clear_button')), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.byKey(const Key('search_bar_clear_button')));
      await tester.pump();

      expect(find.byKey(const Key('search_bar_clear_button')), findsNothing);
    });

    testWidgets(
      'SearchSuggestionsList renders loading, empty, error, and data states',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SearchSuggestionsList(),
            overrides: [
              searchSuggestionsProvider.overrideWith(
                (ref) async => [
                  const SearchSuggestion(
                    id: 'track-1',
                    text: 'Track One',
                    type: 'track',
                  ),
                  const SearchSuggestion(
                    id: 'user-1',
                    text: 'User One',
                    type: 'user',
                  ),
                ],
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('suggestions_list')), findsOneWidget);
        expect(find.text('Track One'), findsOneWidget);
        expect(find.text('User One'), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const SearchSuggestionsList(),
            overrides: [
              searchSuggestionsProvider.overrideWith((ref) async => []),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('suggestions_empty')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const SearchSuggestionsList(),
            overrides: [
              searchSuggestionsProvider.overrideWith(
                (ref) async => throw Exception('boom'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('suggestions_error')), findsOneWidget);
      },
    );

    testWidgets('SearchResultsTabs renders tab bar and result tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SearchResultsTabs(),
          overrides: _searchOverrides(_results()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_tab_bar')), findsOneWidget);
      expect(find.byKey(const Key('search_tab_all')), findsOneWidget);
      expect(find.byKey(const Key('all_tab_list')), findsOneWidget);
    });

    testWidgets('AllTab renders populated and empty summaries', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const AllTab(), overrides: _searchOverrides(_results())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Top Result'), findsOneWidget);
      expect(find.text('Tracks'), findsOneWidget);
      expect(find.byKey(const Key('all_tab_tracks_section')), findsOneWidget);
      expect(find.byKey(const Key('all_tab_profile_0')), findsOneWidget);
      expect(find.byKey(const Key('all_tab_playlist_0')), findsOneWidget);
      expect(find.byKey(const Key('all_tab_album_0')), findsOneWidget);
      expect(find.byKey(const Key('all_tab_more_track_0')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => const SearchResults(tracks: []),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No top result'), findsOneWidget);
    });

    testWidgets('AllTab covers loading, error, and top result variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) => Future<SearchResults>.delayed(
                const Duration(seconds: 1),
                () => _results(),
              ),
            ),
          ],
        ),
      );
      expect(find.byKey(const Key('all_tab_loading')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => throw Exception('all failed'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('all_tab_error')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultUser(
                  const ProfileEntity(
                    id: 'profile-top',
                    displayName: 'Top Profile',
                    username: 'topprofile',
                  ),
                ),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Top Profile'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultPlaylist(_playlistMap()),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Playlist One'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultAlbum(_albumMap()),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Album One'), findsOneWidget);
    });

    testWidgets('AllTab see-all and result taps execute callbacks', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (var index = 0; index < 4; index++) {
        await tester.pumpWidget(
          _wrap(const AllTab(), overrides: _searchOverrides(_results())),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'See all').at(index));
        await tester.pumpAndSettle();
        expect(find.byType(SearchSeeAllPage), findsOneWidget);
      }

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchQueryProvider.overrideWith(SearchQueryNotifier.new),
            searchResultsProvider.overrideWith((ref) async => _results()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Track 1'));
      await tester.pump();

      await tester.tap(find.text('Playlist One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:playlist-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith((ref) async => _results()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:album-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultUser(
                  const ProfileEntity(
                    id: 'profile-top',
                    displayName: 'Top Profile',
                    username: 'topprofile',
                  ),
                ),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Top Profile'));
      await tester.pumpAndSettle();
      expect(find.text('profile:profile-top'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultPlaylist(_playlistMap()),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Playlist One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:playlist-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultAlbum(_albumMap()),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:album-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          const AllTab(),
          overrides: [
            searchResultsProvider.overrideWith(
              (ref) async => SearchResults(
                topResult: TopResultTrack(_track()),
                tracks: const [],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Track One'));
      await tester.pump();
    });

    testWidgets(
      'Tracks, playlists, and albums tabs render data, empty, and error states',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const TracksTab(), overrides: _searchOverrides(_results())),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tracks_list')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const TracksTab(),
            overrides: [
              searchTracksProvider.overrideWith(
                (ref) async => const SearchResults(tracks: []),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tracks_empty')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const TracksTab(),
            overrides: [
              searchTracksProvider.overrideWith(
                (ref) async => throw Exception('tracks'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tracks_error')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(const PlaylistsTab(), overrides: _searchOverrides(_results())),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('playlists_list')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const PlaylistsTab(),
            overrides: [
              searchPlaylistsProvider.overrideWith(
                (ref) async => const SearchResults(tracks: []),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('playlists_empty')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const PlaylistsTab(),
            overrides: [
              searchPlaylistsProvider.overrideWith(
                (ref) async => throw Exception('playlists'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('playlists_error')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(const AlbumsTab(), overrides: _searchOverrides(_results())),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('albums_list')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const AlbumsTab(),
            overrides: [
              searchAlbumsProvider.overrideWith(
                (ref) async => const SearchResults(tracks: []),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('albums_empty')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const AlbumsTab(),
            overrides: [
              searchAlbumsProvider.overrideWith(
                (ref) async => throw Exception('albums'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('albums_error')), findsOneWidget);
      },
    );

    testWidgets('Profiles tab and profile cards render all basic states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ProfilesTab(), overrides: _searchOverrides(_results())),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profiles_list')), findsOneWidget);
      expect(find.text('Profile One'), findsOneWidget);
      expect(find.byKey(const Key('follow_button_profile-1')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const ProfilesTab(),
          overrides: [
            searchProfilesProvider.overrideWith(
              (ref) async => const SearchResults(tracks: []),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profiles_empty')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const ProfilesTab(),
          overrides: [
            searchProfilesProvider.overrideWith(
              (ref) async => throw Exception('profiles'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profiles_error')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const SearchProfileCard(
            profile: ProfileEntity(
              id: 'profile-avatar',
              displayName: 'Counted Profile',
              username: 'countedprofile',
              followersCount: 1500,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Counted Profile'), findsOneWidget);
      expect(find.text('1.5K'), findsOneWidget);
    });

    testWidgets(
      'VibesGrid and SearchScreen render idle, typing, and submitted states',
      (tester) async {
        VibeCategory? tapped;
        final vibes = [_vibe()];
        await tester.pumpWidget(
          _wrap(VibesGrid(vibes: vibes, onVibeTap: (v) => tapped = v)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('vibe_card_rock')));
        expect(tapped?.id, 'rock');

        await tester.pumpWidget(
          _wrap(
            const SearchScreen(),
            overrides: [vibesProvider.overrideWith((ref) async => vibes)],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('vibes_section')), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            const SearchScreen(),
            overrides: [
              searchQueryProvider.overrideWith(SearchQueryNotifier.new),
              searchSubmittedProvider.overrideWith(SearchSubmittedNotifier.new),
              vibesProvider.overrideWith((ref) async => vibes),
              ..._searchOverrides(_results()),
              searchSuggestionsProvider.overrideWith(
                (ref) async => [
                  const SearchSuggestion(
                    id: 'track-1',
                    text: 'Track One',
                    type: 'track',
                  ),
                ],
              ),
            ],
          ),
        );
        await tester.enterText(
          find.byKey(const Key('search_bar_field')),
          'Track',
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('search_suggestions_list')),
          findsOneWidget,
        );

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('search_results_tabs')), findsOneWidget);
      },
    );

    testWidgets('SearchScreen renders vibe loading and error states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SearchScreen(),
          overrides: [
            vibesProvider.overrideWith(
              (ref) => Future<List<VibeCategory>>.delayed(
                const Duration(seconds: 1),
                () => [_vibe()],
              ),
            ),
          ],
        ),
      );
      expect(find.byKey(const Key('vibes_loading')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const SearchScreen(),
          overrides: [
            vibesProvider.overrideWith(
              (ref) async => throw Exception('vibes failed'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('vibes_error')), findsOneWidget);
    });

    testWidgets('See-all pages and track tile render', (tester) async {
      await tester.pumpWidget(
        _wrap(const SearchSeeAllPage(title: 'Tracks', child: Text('Body'))),
      );
      expect(find.text('Tracks'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const GenreSeeAllPage(
            title: 'Genre Tracks',
            child: Text('Genre Body'),
          ),
        ),
      );
      expect(find.text('Genre Tracks'), findsOneWidget);
      expect(find.text('Genre Body'), findsOneWidget);

      await tester.pumpWidget(_wrap(TrackTile(track: _track())));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('track_tile_track-1')), findsOneWidget);
      expect(find.text('Track One'), findsOneWidget);

      await tester.tap(find.byKey(const Key('track_tile_track-1')));
      await tester.pump();

      await tester.pumpWidget(
        _wrap(
          TrackTile(
            track: _track(id: 'empty-art', coverImage: ''),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('track_tile_empty-art')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          TrackTile(
            track: _track(
              id: 'remote-art',
              coverImage: 'https://example.com/track.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('track_tile_remote-art')), findsOneWidget);

      var customTapped = false;
      await tester.pumpWidget(
        _wrap(
          TrackTile(
            track: _track(id: 'custom-track'),
            onTap: () {
              customTapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('track_tile_custom-track')));
      expect(customTapped, isTrue);

      await tester.pumpWidget(
        _wrap(TrackTile(track: _track()), loadedPlayer: true),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('track_tile_track-1')));
      await tester.pump();
    });
  });

  group('genre presentation widgets', () {
    testWidgets('GenrePage renders header tabs and all tab content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const GenrePage(
            genreId: 'rock',
            genreName: 'Rock',
            coverImage: 'assets/images/vibes_1.jpeg',
          ),
          overrides: _genreOverrides(_content()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('genre_page')), findsOneWidget);
      expect(find.text('Rock'), findsOneWidget);
      expect(find.byKey(const Key('genre_tab_bar')), findsOneWidget);
      expect(find.byKey(const Key('genre_all_list')), findsOneWidget);
    });

    testWidgets('Genre tabs render data, empty, and error states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          GenreTrendingTab(genreId: 'rock'),
          overrides: _genreOverrides(_content()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_trending_content')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreTrendingTab(genreId: 'rock'),
          overrides: [
            genreTracksProvider('rock').overrideWith((ref) async => <Track>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_trending_empty')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreTrendingTab(genreId: 'rock'),
          overrides: [
            genreTracksProvider(
              'rock',
            ).overrideWith((ref) async => throw Exception('trending')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_trending_error')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenrePlaylistsTab(genreId: 'rock'),
          overrides: _genreOverrides(_content()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_playlists_content')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenrePlaylistsTab(genreId: 'rock'),
          overrides: [
            genrePlaylistsProvider(
              'rock',
            ).overrideWith((ref) async => <GenrePlaylist>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_playlists_empty')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenrePlaylistsTab(genreId: 'rock'),
          overrides: [
            genrePlaylistsProvider(
              'rock',
            ).overrideWith((ref) async => throw Exception('playlists')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_playlists_error')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAlbumsTab(genreId: 'rock'),
          overrides: _genreOverrides(_content()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_albums_content')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAlbumsTab(genreId: 'rock'),
          overrides: [
            genreAlbumsProvider(
              'rock',
            ).overrideWith((ref) async => <GenreAlbum>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_albums_empty')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAlbumsTab(genreId: 'rock'),
          overrides: [
            genreAlbumsProvider(
              'rock',
            ).overrideWith((ref) async => throw Exception('albums')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_albums_error')), findsOneWidget);
    });

    testWidgets('Genre all tab, all tracks, and cards render key states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          GenreAllTab(genreId: 'rock'),
          overrides: [
            genreContentProvider('rock').overrideWith(
              (ref) => Future<GenreContent>.delayed(
                const Duration(seconds: 1),
                () => _content(),
              ),
            ),
          ],
        ),
      );
      expect(find.byKey(const Key('genre_all_loading')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAllTab(genreId: 'rock'),
          overrides: [
            genreContentProvider(
              'rock',
            ).overrideWith((ref) async => throw Exception('genre all')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_all_error')), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(1200, 3600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          GenreAllTab(genreId: 'rock'),
          overrides: _genreOverrides(_contentWithoutArtists()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_all_list')), findsOneWidget);
      expect(find.byKey(const Key('genre_trending_see_all')), findsOneWidget);
      expect(find.byKey(const Key('genre_playlists_grid')), findsOneWidget);
      expect(find.byKey(const Key('genre_albums_grid')), findsOneWidget);
      expect(find.byKey(const Key('genre_discover_track_0')), findsOneWidget);

      for (var index = 0; index < 3; index++) {
        await tester.pumpWidget(
          _wrap(
            GenreAllTab(genreId: 'rock'),
            overrides: _genreOverrides(_contentWithoutArtists()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'See all').at(index));
        await tester.pumpAndSettle();
        expect(find.byType(GenreSeeAllPage), findsOneWidget);
      }

      await tester.pumpWidget(
        _wrap(
          GenreAllTracksList(genreId: 'rock'),
          overrides: _genreOverrides(_content()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_all_tracks_list')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAllTracksList(genreId: 'rock'),
          overrides: [
            genreAllTracksProvider(
              'rock',
            ).overrideWith((ref) async => <Track>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_all_tracks_empty')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          GenreAllTracksList(genreId: 'rock'),
          overrides: [
            genreAllTracksProvider(
              'rock',
            ).overrideWith((ref) async => throw Exception('all tracks')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('genre_all_tracks_error')), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          ListView(
            children: [
              GenrePlaylistCard(playlist: _playlist()),
              GenreAlbumCard(album: _album()),
              GenrePlaylistCard(playlist: _playlist(coverImage: '')),
              GenreAlbumCard(album: _album(coverImage: '')),
              IntroducingWidget(introducing: _introducing()),
              IntroducingSectionWidget(introducing: _introducing()),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Playlist One'), findsAtLeastNWidgets(1));
      expect(find.text('Album One'), findsAtLeastNWidgets(1));

      await tester.pumpWidget(
        _wrapRouter(
          ListView(
            children: [
              GenrePlaylistCard(
                playlist: _playlist(coverImage: 'https://example.com/p.png'),
              ),
              GenreAlbumCard(
                album: _album(coverImage: 'https://example.com/a.png'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Playlist One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:playlist-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrapRouter(
          ListView(
            children: [
              GenreAlbumCard(
                album: _album(coverImage: 'https://example.com/a.png'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album One'));
      await tester.pumpAndSettle();
      expect(find.text('playlist:album-1'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          ListView(
            children: [
              SizedBox(
                height: 220,
                child: TrendingTracks(tracks: _tracks(), genreId: 'rock'),
              ),
              SizedBox(
                height: 220,
                child: TrendingTracks(
                  tracks: [_track(id: 'remote-track', coverImage: 'https://x')],
                  genreId: 'rock',
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('trending_tracks_list')),
        findsAtLeastNWidgets(1),
      );

      await tester.tap(find.byKey(const Key('trending_track_track-1')));
      await tester.pump();

      await tester.pumpWidget(
        _wrap(IntroducingSectionWidget(introducing: _introducing())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      await tester.pumpWidget(
        _wrap(
          IntroducingSectionWidget(introducing: _introducing()),
          playingPlayer: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.pause), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause).first);
      await tester.pump();
    });

    testWidgets('GenreProfileCard renders asset and fallback avatars', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              GenreProfileCard(
                artist: GenreArtist(
                  id: 'artist-empty',
                  displayName: 'Empty Artist',
                  username: 'emptyartist',
                  profilePicture: '',
                  isVerified: false,
                  followerCount: 42,
                  trackCountInGenre: 2,
                ),
              ),
              GenreProfileCard(
                artist: GenreArtist(
                  id: 'artist-asset',
                  displayName: 'Asset Artist',
                  username: 'assetartist',
                  profilePicture: 'assets/images/vibes_1.jpeg',
                  isVerified: true,
                  followerCount: 84,
                  trackCountInGenre: 4,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('genre_profile_avatar_artist-empty')),
        findsOneWidget,
      );
      expect(find.text('Empty Artist'), findsOneWidget);
      expect(find.text('Asset Artist'), findsOneWidget);
    });
  });
}

Widget _wrap(
  Widget child, {
  List overrides = const [],
  bool loadedPlayer = false,
  bool playingPlayer = false,
}) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      if (playingPlayer)
        playerStateProvider.overrideWith(FakePlayingPlayerNotifier.new)
      else if (loadedPlayer)
        playerStateProvider.overrideWith(FakeLoadedPlayerNotifier.new)
      else
        playerStateProvider.overrideWith(FakePlayerNotifier.new),
      queueStateProvider.overrideWith(FakeQueueNotifier.new),
      ...overrides,
    ],
    child: MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: child),
    ),
  );
}

Widget _wrapRouter(
  Widget child, {
  List overrides = const [],
  bool loadedPlayer = false,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/home/playlist/:id',
        builder: (_, state) =>
            Scaffold(body: Text('playlist:${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/home/profile/:id',
        builder: (_, state) =>
            Scaffold(body: Text('profile:${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      if (loadedPlayer)
        playerStateProvider.overrideWith(FakeLoadedPlayerNotifier.new)
      else
        playerStateProvider.overrideWith(FakePlayerNotifier.new),
      queueStateProvider.overrideWith(FakeQueueNotifier.new),
      ...overrides,
    ],
    child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
  );
}

List _searchOverrides(SearchResults results) => [
  searchResultsProvider.overrideWith((ref) async => results),
  searchTracksProvider.overrideWith((ref) async => results),
  searchProfilesProvider.overrideWith((ref) async => results),
  searchPlaylistsProvider.overrideWith((ref) async => results),
  searchAlbumsProvider.overrideWith((ref) async => results),
];

List _genreOverrides(GenreContent content) => [
  genreContentProvider('rock').overrideWith((ref) async => content),
  genreTracksProvider('rock').overrideWith((ref) async => content.tracks),
  genrePlaylistsProvider('rock').overrideWith((ref) async => content.playlists),
  genreAlbumsProvider('rock').overrideWith((ref) async => content.albums),
  genreArtistsProvider('rock').overrideWith((ref) async => content.artists),
  genreAllTracksProvider('rock').overrideWith((ref) async => content.tracks),
];

SearchResults _results() => SearchResults(
  topResult: TopResultTrack(_track()),
  tracks: _tracks(),
  profiles: const [
    ProfileEntity(
      id: 'profile-1',
      displayName: 'Profile One',
      username: 'profileone',
    ),
  ],
  playlists: [_playlistMap()],
  albums: [_albumMap()],
);

GenreContent _content() => GenreContent(
  genreInfo: const GenreInfo(
    id: 'rock',
    name: 'Rock',
    coverImage: 'assets/images/vibes_1.jpeg',
    trackCount: 4,
    artistCount: 1,
    playlistCount: 1,
    albumCount: 1,
  ),
  introducing: _introducing(),
  playlists: [_playlist()],
  albums: [_album()],
  artists: const [
    GenreArtist(
      id: 'artist-1',
      displayName: 'Artist One',
      username: 'artistone',
      profilePicture: '',
      isVerified: true,
      followerCount: 100,
      trackCountInGenre: 4,
    ),
  ],
  tracks: _tracks(),
);

GenreContent _contentWithoutArtists() => GenreContent(
  genreInfo: const GenreInfo(
    id: 'rock',
    name: 'Rock',
    coverImage: 'assets/images/vibes_1.jpeg',
    trackCount: 4,
    artistCount: 0,
    playlistCount: 1,
    albumCount: 1,
  ),
  introducing: _introducing(),
  playlists: [_playlist()],
  albums: [_album()],
  artists: const [],
  tracks: _tracks(),
);

IntroducingSection _introducing() => IntroducingSection(
  playlist: IntroducingPlaylist(
    playlistId: 'playlist-1',
    ownerUserId: 'owner-1',
    name: 'Playlist One',
    description: 'Intro description',
    isPublic: true,
    createdAt: DateTime(2026, 1, 1),
    trackCount: 2,
    likeCount: 10,
    coverImage: 'assets/images/vibes_1.jpeg',
    previewTrack: _track(),
  ),
  tracksPreview: _tracks().take(2).toList(),
);

List<Track> _tracks() => List.generate(
  5,
  (index) => _track(id: 'track-${index + 1}', title: 'Track ${index + 1}'),
);

Track _track({
  String id = 'track-1',
  String title = 'Track One',
  String coverImage = 'assets/images/vibes_1.jpeg',
}) => Track(
  id: id,
  userId: 'user-1',
  title: title,
  artist: 'Artist One',
  audioUrl: 'audio.mp3',
  coverImage: coverImage,
  duration: const Duration(seconds: 180),
  playCount: 1200,
  createdAt: DateTime(2026, 1, 1),
);

GenrePlaylist _playlist({String coverImage = 'assets/images/vibes_1.jpeg'}) =>
    GenrePlaylist(
      id: 'playlist-1',
      name: 'Playlist One',
      coverImage: coverImage,
      ownerId: 'owner-1',
      ownerName: 'Owner One',
      trackCount: 12,
      likeCount: 10,
      source: 'tagged',
      createdAt: DateTime(2026, 1, 1),
    );

GenreAlbum _album({String coverImage = 'assets/images/vibes_1.jpeg'}) =>
    GenreAlbum(
      id: 'album-1',
      name: 'Album One',
      coverImage: coverImage,
      ownerId: 'owner-1',
      ownerName: 'Artist One',
      trackCount: 8,
      likeCount: 16,
      releaseDate: '2026-01-01',
    );

Map<String, String> _playlistMap() => {
  'id': 'playlist-1',
  'title': 'Playlist One',
  'creator': 'Creator One',
  'trackCount': '12',
  'totalSeconds': '3600',
  'artworkUrl': '',
};

Map<String, String> _albumMap() => {
  'id': 'album-1',
  'title': 'Album One',
  'artist': 'Artist One',
  'year': '2026',
  'type': 'Album',
  'artworkUrl': '',
};

VibeCategory _vibe() => const VibeCategory(
  id: 'rock',
  title: 'Rock',
  imagePath: 'assets/images/vibes_1.jpeg',
  height: 120,
  color: Colors.red,
);
