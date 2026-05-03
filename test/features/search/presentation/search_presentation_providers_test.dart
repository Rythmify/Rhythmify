import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/search/data/datasources/search_remote_datasource.dart';
import 'package:rythmify/features/search/data/datasources/vibes_genre_remote_datasource.dart';
import 'package:rythmify/features/search/data/datasources/vibes_remote_datasource.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_album.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_artists.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_info.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_playlist.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_playlist.dart';
import 'package:rythmify/features/search/presentation/providers/search_providers.dart';
import 'package:rythmify/features/search/presentation/providers/vibes_genre_providers.dart';
import 'package:rythmify/features/search/presentation/providers/vibes_providers.dart';

class FakeSearchRemoteSource implements SearchRemoteSource {
  String? lastSuggestionsQuery;
  String? lastResultsQuery;
  String? lastTypedQuery;
  String? lastTypedType;

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    lastSuggestionsQuery = query;
    return const [SearchSuggestion(id: 's1', text: 'Song', type: 'track')];
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    lastResultsQuery = query;
    return _results();
  }

  @override
  Future<SearchResults> getSearchResultsTyped(String query, String type) async {
    lastTypedQuery = query;
    lastTypedType = type;
    return switch (type) {
      'tracks' => SearchResults(tracks: [_track()]),
      'users' => const SearchResults(
        tracks: [],
        profiles: [ProfileEntity(id: 'p1', displayName: 'Profile One')],
      ),
      'playlists' => const SearchResults(
        tracks: [],
        playlists: [
          {'id': 'pl1', 'title': 'Playlist One'},
        ],
      ),
      'albums' => const SearchResults(
        tracks: [],
        albums: [
          {'id': 'al1', 'title': 'Album One'},
        ],
      ),
      _ => const SearchResults(tracks: []),
    };
  }
}

class FakeVibesRemoteSource implements VibesRemoteSource {
  @override
  Future<List<VibeCategory>> getVibes() async => const [
    VibeCategory(
      id: 'rock',
      title: 'Rock',
      imagePath: 'assets/images/vibes_1.jpeg',
      height: 120,
      color: Color(0xFFFF0000),
    ),
  ];
}

class FakeGenreRemoteSource implements GenreRemoteSource {
  @override
  Future<GenreContent> getGenreContent(String genreId) async => _content();

  @override
  Future<List<Track>> getGenreTrendingTracks(String genreId) async => [
    _track(),
  ];

  @override
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId) async => [
    _playlist(),
  ];

  @override
  Future<List<GenreAlbum>> getGenreAlbums(String genreId) async => [_album()];

  @override
  Future<List<GenreArtist>> getGenreArtists(String genreId) async => const [
    GenreArtist(
      id: 'artist-1',
      displayName: 'Artist One',
      username: 'artistone',
      profilePicture: '',
      isVerified: true,
      followerCount: 100,
      trackCountInGenre: 3,
    ),
  ];

  @override
  Future<List<Track>> getGenreAllTracks(String genreId) async => [_track()];
}

void main() {
  group('search providers', () {
    test('notifiers update, submit, and reset state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
      container.read(searchQueryProvider.notifier).update('rock');
      expect(container.read(searchQueryProvider), 'rock');

      expect(container.read(searchSubmittedProvider), false);
      container.read(searchSubmittedProvider.notifier).submit();
      expect(container.read(searchSubmittedProvider), true);
      container.read(searchSubmittedProvider.notifier).reset();
      expect(container.read(searchSubmittedProvider), false);
    });

    test('search providers return empty results for blank queries', () async {
      final container = ProviderContainer(
        overrides: [
          searchRemoteSourceProvider.overrideWithValue(
            FakeSearchRemoteSource(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container.read(searchTracksProvider.future),
        isA<SearchResults>(),
      );
      expect(
        (await container.read(searchProfilesProvider.future)).profiles,
        isEmpty,
      );
      expect(
        (await container.read(searchPlaylistsProvider.future)).playlists,
        isEmpty,
      );
      expect(
        (await container.read(searchAlbumsProvider.future)).albums,
        isEmpty,
      );
      expect(
        (await container.read(searchResultsProvider.future)).tracks,
        isEmpty,
      );
      expect(await container.read(searchSuggestionsProvider.future), isEmpty);
    });

    test(
      'search providers delegate non-empty queries through repository graph',
      () async {
        final fake = FakeSearchRemoteSource();
        final container = ProviderContainer(
          overrides: [searchRemoteSourceProvider.overrideWithValue(fake)],
        );
        addTearDown(container.dispose);

        container.read(searchQueryProvider.notifier).update('rock');

        expect(container.read(searchRepositoryProvider), isNotNull);
        expect(container.read(getSearchSuggestionsProvider), isNotNull);
        expect(container.read(getSearchResultsProvider), isNotNull);
        expect(
          (await container.read(searchResultsProvider.future)).tracks,
          isNotEmpty,
        );
        expect(
          (await container.read(searchTracksProvider.future)).tracks,
          isNotEmpty,
        );
        expect(
          (await container.read(searchProfilesProvider.future)).profiles,
          isNotEmpty,
        );
        expect(
          (await container.read(searchPlaylistsProvider.future)).playlists,
          isNotEmpty,
        );
        expect(
          (await container.read(searchAlbumsProvider.future)).albums,
          isNotEmpty,
        );
        expect(fake.lastResultsQuery, 'rock');
        expect(fake.lastTypedQuery, 'rock');
        expect(fake.lastTypedType, 'albums');
      },
    );
  });

  group('vibes providers', () {
    test('vibes provider delegates through repository graph', () async {
      final container = ProviderContainer(
        overrides: [
          vibesRemoteSourceProvider.overrideWithValue(FakeVibesRemoteSource()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(vibesRepositoryProvider), isNotNull);
      expect(container.read(getVibesProvider), isNotNull);
      final vibes = await container.read(vibesProvider.future);
      expect(vibes.single.id, 'rock');
    });
  });

  group('genre providers', () {
    test('genre providers delegate through repository graph', () async {
      final container = ProviderContainer(
        overrides: [
          genreRemoteSourceProvider.overrideWithValue(FakeGenreRemoteSource()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(genreRepositoryProvider), isNotNull);
      expect(container.read(getGenreContentProvider), isNotNull);
      expect(container.read(getGenreTracksProvider), isNotNull);
      expect(container.read(getGenrePlaylistsProvider), isNotNull);
      expect(container.read(getGenreAlbumsProvider), isNotNull);
      expect(container.read(getGenreArtistsProvider), isNotNull);
      expect(container.read(getGenreAllTracksProvider), isNotNull);
      expect(
        (await container.read(
          genreContentProvider('rock').future,
        )).genreInfo.id,
        'rock',
      );
      expect(
        await container.read(genreTracksProvider('rock').future),
        isNotEmpty,
      );
      expect(
        await container.read(genrePlaylistsProvider('rock').future),
        isNotEmpty,
      );
      expect(
        await container.read(genreAlbumsProvider('rock').future),
        isNotEmpty,
      );
      expect(
        await container.read(genreArtistsProvider('rock').future),
        isNotEmpty,
      );
      expect(
        await container.read(genreAllTracksProvider('rock').future),
        isNotEmpty,
      );
    });
  });
}

SearchResults _results() => SearchResults(tracks: [_track()]);

Track _track() => Track(
  id: 'track-1',
  userId: 'user-1',
  title: 'Track One',
  artist: 'Artist One',
  audioUrl: 'audio.mp3',
  coverImage: 'assets/images/vibes_1.jpeg',
  duration: const Duration(seconds: 180),
  createdAt: DateTime(2026, 1, 1),
);

GenreContent _content() => GenreContent(
  genreInfo: const GenreInfo(
    id: 'rock',
    name: 'Rock',
    coverImage: '',
    trackCount: 1,
    artistCount: 1,
    playlistCount: 1,
    albumCount: 1,
  ),
  introducing: IntroducingSection(
    playlist: IntroducingPlaylist(
      playlistId: 'playlist-1',
      ownerUserId: 'owner-1',
      name: 'Playlist One',
      description: '',
      isPublic: true,
      createdAt: DateTime(2026, 1, 1),
      trackCount: 1,
      likeCount: 1,
      coverImage: 'assets/images/vibes_1.jpeg',
      previewTrack: _track(),
    ),
    tracksPreview: [_track()],
  ),
  playlists: [_playlist()],
  albums: [_album()],
  artists: const [],
  tracks: [_track()],
);

GenrePlaylist _playlist() => GenrePlaylist(
  id: 'playlist-1',
  name: 'Playlist One',
  coverImage: 'assets/images/vibes_1.jpeg',
  ownerId: 'owner-1',
  ownerName: 'Owner One',
  trackCount: 1,
  likeCount: 1,
  source: 'tagged',
  createdAt: DateTime(2026, 1, 1),
);

GenreAlbum _album() => const GenreAlbum(
  id: 'album-1',
  name: 'Album One',
  coverImage: 'assets/images/vibes_1.jpeg',
  ownerId: 'owner-1',
  ownerName: 'Artist One',
  trackCount: 1,
  likeCount: 1,
  releaseDate: '2026-01-01',
);
