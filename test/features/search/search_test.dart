import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/search/data/datasources/search_remote_datasource.dart';
import 'package:rythmify/features/search/data/repositories/search_repository_impl.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/repositories/search_repository.dart';
import 'package:rythmify/features/search/domain/usecases/get_search_results.dart';
import 'package:rythmify/features/search/domain/usecases/get_search_suggestions.dart';
import 'package:rythmify/features/search/presentation/providers/search_providers.dart';

void main() {
  group('Search Feature Tests', () {
    // ==================== Entity Tests ====================
    group('SearchSuggestion Entity', () {
      test('should create SearchSuggestion with all required properties', () {
        // Arrange
        const suggestion = SearchSuggestion(
          id: '1',
          text: 'Blinding Lights',
          type: 'track',
        );

        // Act & Assert
        expect(suggestion.id, '1');
        expect(suggestion.text, 'Blinding Lights');
        expect(suggestion.type, 'track');
      });

      test('should support equality comparison', () {
        // Arrange
        const suggestion1 = SearchSuggestion(
          id: '1',
          text: 'Blinding Lights',
          type: 'track',
        );
        const suggestion2 = SearchSuggestion(
          id: '1',
          text: 'Blinding Lights',
          type: 'track',
        );
        const suggestion3 = SearchSuggestion(
          id: '2',
          text: 'Save Your Tears',
          type: 'track',
        );

        // Act & Assert
        expect(suggestion1, suggestion2);
        expect(suggestion1, isNot(suggestion3));
      });

      test('should create suggestions with different types', () {
        // Arrange
        const trackSuggestion = SearchSuggestion(
          id: '1',
          text: 'Blinding Lights',
          type: 'track',
        );
        const userSuggestion = SearchSuggestion(
          id: '2',
          text: 'The Weeknd',
          type: 'user',
        );
        const playlistSuggestion = SearchSuggestion(
          id: '3',
          text: 'Chill Vibes',
          type: 'playlist',
        );

        // Act & Assert
        expect(trackSuggestion.type, 'track');
        expect(userSuggestion.type, 'user');
        expect(playlistSuggestion.type, 'playlist');
      });
    });

    group('SearchResults Entity', () {
      late Track mockTrack;

      setUp(() {
        mockTrack = Track(
          id: 't1',
          userId: 'u1',
          title: 'Test Track',
          artist: 'Test Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: const Duration(minutes: 3),
          createdAt: DateTime.now(),
          coverImage: 'assets/images/placeholder.png',
          genre: 'Pop',
          playCount: 100,
          likeCount: 50,
          commentCount: 10,
          repostCount: 5,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );
      });

      test('should create SearchResults with all properties', () {
        // Arrange
        final searchResults = SearchResults(
          tracks: [mockTrack],
          playlists: const [
            {'id': 'p1', 'name': 'Playlist 1'},
          ],
          profiles: const [],
          albums: const [
            {'id': 'a1', 'name': 'Album 1'},
          ],
        );

        // Act & Assert
        expect(searchResults.tracks.length, 1);
        expect(searchResults.tracks.first.title, 'Test Track');
        expect(searchResults.playlists.length, 1);
        expect(searchResults.albums.length, 1);
        expect(searchResults.profiles, isEmpty);
      });

      test('should create SearchResults with only tracks', () {
        // Arrange
        final searchResults = SearchResults(tracks: [mockTrack]);

        // Act & Assert
        expect(searchResults.tracks.length, 1);
        expect(searchResults.playlists, isEmpty);
        expect(searchResults.profiles, isEmpty);
        expect(searchResults.albums, isEmpty);
      });

      test('should have default empty lists for optional fields', () {
        // Arrange
        final searchResults = SearchResults(tracks: []);

        // Act & Assert
        expect(searchResults.tracks, isEmpty);
        expect(searchResults.playlists, isEmpty);
        expect(searchResults.profiles, isEmpty);
        expect(searchResults.albums, isEmpty);
      });

      test('should handle multiple tracks', () {
        // Arrange
        final mockTrack2 = Track(
          id: 't2',
          userId: 'u2',
          title: 'Another Track',
          artist: 'Another Artist',
          audioUrl: 'https://example.com/audio2.mp3',
          duration: const Duration(minutes: 4),
          createdAt: DateTime.now(),
          coverImage: 'assets/images/placeholder.png',
          genre: 'Rock',
          playCount: 200,
          likeCount: 75,
          commentCount: 20,
          repostCount: 10,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );

        final searchResults = SearchResults(tracks: [mockTrack, mockTrack2]);

        // Act & Assert
        expect(searchResults.tracks.length, 2);
        expect(searchResults.tracks.first.title, 'Test Track');
        expect(searchResults.tracks.last.title, 'Another Track');
      });
    });

    // ==================== Data Source Tests ====================
    group('SearchRemoteSource', () {
      late SearchRemoteSourceMock searchRemoteSource;

      setUp(() {
        searchRemoteSource = SearchRemoteSourceMock();
      });

      test('should return suggestions for a valid query', () async {
        // Act
        final suggestions = await searchRemoteSource.getSuggestions('Blinding');

        // Assert
        expect(suggestions.isNotEmpty, true);
      });

      test('should return list of SearchSuggestion', () async {
        // Act
        final suggestions = await searchRemoteSource.getSuggestions('The');

        // Assert
        expect(suggestions, isA<List<SearchSuggestion>>());
        for (var suggestion in suggestions) {
          expect(suggestion, isA<SearchSuggestion>());
          expect(suggestion.id, isNotEmpty);
          expect(suggestion.text, isNotEmpty);
          expect(suggestion.type, isNotEmpty);
        }
      });

      test('should return SearchResults with tracks', () async {
        // Act
        final results = await searchRemoteSource.getSearchResults('Weeknd');

        // Assert
        expect(results, isA<SearchResults>());
        expect(results.tracks.isNotEmpty, true);
        expect(results.tracks.first, isA<Track>());
      });

      test('should return SearchResults with profiles', () async {
        // Act
        final results = await searchRemoteSource.getSearchResults('Weeknd');

        // Assert
        expect(results, isA<SearchResults>());
        expect(results.profiles.isNotEmpty, true);
      });

      test('should handle empty results gracefully', () async {
        // Act
        final suggestions = await searchRemoteSource.getSuggestions('');

        // Assert
        expect(suggestions, isA<List<SearchSuggestion>>());
      });

      test('should return tracks with required properties', () async {
        // Act
        final results = await searchRemoteSource.getSearchResults('Weeknd');

        // Assert
        expect(results.tracks.isNotEmpty, true);
        for (var track in results.tracks) {
          expect(track.id, isNotEmpty);
          expect(track.title, isNotEmpty);
          expect(track.artist, isNotEmpty);
          expect(track.audioUrl, isNotNull);
          expect(track.duration, isNotNull);
          expect(track.genre, isNotNull);
        }
      });
    });

    // ==================== Repository Tests ====================
    group('SearchRepository', () {
      late SearchRemoteSourceMock mockRemoteSource;
      late SearchRepository searchRepository;

      setUp(() {
        mockRemoteSource = SearchRemoteSourceMock();
        searchRepository = SearchRepositoryImpl(remoteSource: mockRemoteSource);
      });

      test('should delegate getSuggestions to remote source', () async {
        // Act
        final suggestions = await searchRepository.getSuggestions('The');

        // Assert
        expect(suggestions, isA<List<SearchSuggestion>>());
        expect(suggestions.isNotEmpty, true);
      });

      test('should delegate getSearchResults to remote source', () async {
        // Act
        final results = await searchRepository.getSearchResults('Weeknd');

        // Assert
        expect(results, isA<SearchResults>());
        expect(results.tracks.isNotEmpty, true);
      });

      test('should handle queries with special characters', () async {
        // Act
        final suggestions = await searchRepository.getSuggestions('The Weeknd');

        // Assert
        expect(suggestions, isA<List<SearchSuggestion>>());
      });

      test('should return results with correct types', () async {
        // Act
        final results = await searchRepository.getSearchResults('Weeknd');

        // Assert
        expect(results.tracks, isA<List<Track>>());
        expect(results.playlists, isA<List<Map<String, String>>>());
        expect(results.profiles, isA<List>());
        expect(results.albums, isA<List<Map<String, String>>>());
      });
    });

    // ==================== Use Case Tests ====================
    group('GetSearchSuggestions UseCase', () {
      late GetSearchSuggestions getSearchSuggestions;
      late MockSearchRepository mockRepository;

      setUp(() {
        mockRepository = MockSearchRepository();
        getSearchSuggestions = GetSearchSuggestions(mockRepository);
      });

      test(
        'should call repository.getSuggestions with correct query',
        () async {
          // Arrange
          const query = 'test query';
          final expectedSuggestions = [
            const SearchSuggestion(id: '1', text: 'test query', type: 'track'),
          ];
          mockRepository.mockSuggestions = expectedSuggestions;

          // Act
          final result = await getSearchSuggestions.call(query);

          // Assert
          expect(result, expectedSuggestions);
        },
      );

      test('should return empty list when no suggestions found', () async {
        // Arrange
        mockRepository.mockSuggestions = [];

        // Act
        final result = await getSearchSuggestions.call('non-existent');

        // Assert
        expect(result, isEmpty);
      });

      test('should return multiple suggestions', () async {
        // Arrange
        final suggestions = [
          const SearchSuggestion(id: '1', text: 'Track 1', type: 'track'),
          const SearchSuggestion(id: '2', text: 'Track 2', type: 'track'),
          const SearchSuggestion(id: '3', text: 'Artist', type: 'user'),
        ];
        mockRepository.mockSuggestions = suggestions;

        // Act
        final result = await getSearchSuggestions.call('test');

        // Assert
        expect(result.length, 3);
        expect(result, suggestions);
      });
    });

    group('GetSearchResults UseCase', () {
      late GetSearchResults getSearchResults;
      late MockSearchRepository mockRepository;
      late Track mockTrack;

      setUp(() {
        mockTrack = Track(
          id: 't1',
          userId: 'u1',
          title: 'Test Track',
          artist: 'Test Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: const Duration(minutes: 3),
          createdAt: DateTime.now(),
          coverImage: 'assets/images/placeholder.png',
          genre: 'Pop',
          playCount: 100,
          likeCount: 50,
          commentCount: 10,
          repostCount: 5,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );

        mockRepository = MockSearchRepository();
        getSearchResults = GetSearchResults(mockRepository);
      });

      test(
        'should call repository.getSearchResults with correct query',
        () async {
          // Arrange
          const query = 'weeknd';
          final expectedResults = SearchResults(tracks: [mockTrack]);
          mockRepository.mockResults = expectedResults;

          // Act
          final result = await getSearchResults.call(query);

          // Assert
          expect(result.tracks.length, 1);
          expect(result.tracks.first.title, 'Test Track');
        },
      );

      test('should return empty results when query has no matches', () async {
        // Arrange
        mockRepository.mockResults = const SearchResults(tracks: []);

        // Act
        final result = await getSearchResults.call('non-existent');

        // Assert
        expect(result.tracks, isEmpty);
      });

      test('should return tracks, playlists, and profiles', () async {
        // Arrange
        final results = SearchResults(
          tracks: [mockTrack],
          playlists: const [
            {'id': 'p1', 'name': 'Playlist'},
          ],
          profiles: const [],
          albums: const [
            {'id': 'a1', 'name': 'Album'},
          ],
        );
        mockRepository.mockResults = results;

        // Act
        final result = await getSearchResults.call('test');

        // Assert
        expect(result.tracks, isNotEmpty);
        expect(result.playlists, isNotEmpty);
        expect(result.albums, isNotEmpty);
      });
    });

    // ==================== Provider Tests ====================
    group('Search Providers', () {
      test('SearchQueryNotifier should update state', () {
        // Arrang
        final container = ProviderContainer();

        // Act
        final state1 = container.read(searchQueryProvider);
        expect(state1, isEmpty);

        container.read(searchQueryProvider.notifier).update('test query');
        final state2 = container.read(searchQueryProvider);

        // Assert
        expect(state2, 'test query');
      });

      test('SearchSubmittedNotifier should track submission state', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final initialState = container.read(searchSubmittedProvider);
        expect(initialState, false);

        container.read(searchSubmittedProvider.notifier).submit();
        final submittedState = container.read(searchSubmittedProvider);
        expect(submittedState, true);

        container.read(searchSubmittedProvider.notifier).reset();
        final resetState = container.read(searchSubmittedProvider);

        // Assert
        expect(resetState, false);
      });

      test('searchRepositoryProvider should provide SearchRepository', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final repository = container.read(searchRepositoryProvider);

        // Assert
        expect(repository, isA<SearchRepository>());
      });

      test(
        'getSearchSuggestionsProvider should provide GetSearchSuggestions',
        () {
          // Arrange
          final container = ProviderContainer();

          // Act
          final useCase = container.read(getSearchSuggestionsProvider);

          // Assert
          expect(useCase, isA<GetSearchSuggestions>());
        },
      );

      test('getSearchResultsProvider should provide GetSearchResults', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final useCase = container.read(getSearchResultsProvider);

        // Assert
        expect(useCase, isA<GetSearchResults>());
      });
    });

    // ==================== Integration Tests ====================
    group('Search Feature Integration', () {
      late SearchRemoteSourceMock remoteSource;
      late SearchRepository repository;

      setUp(() {
        remoteSource = SearchRemoteSourceMock();
        repository = SearchRepositoryImpl(remoteSource: remoteSource);
      });

      test('should perform complete search flow', () async {
        // Arrange
        const query = 'Weeknd';

        // Act
        final suggestions = await repository.getSuggestions(query);
        final results = await repository.getSearchResults(query);

        // Assert
        expect(suggestions, isA<List<SearchSuggestion>>());
        expect(results, isA<SearchResults>());
        expect(results.tracks.isNotEmpty, true);
      });

      test('should handle multiple sequential searches', () async {
        // Act & Assert
        final results1 = await repository.getSearchResults('Weeknd');
        expect(results1.tracks.isNotEmpty, true);

        final results2 = await repository.getSearchResults('Billie');
        expect(results2.tracks.isNotEmpty, true);

        final results3 = await repository.getSearchResults('Save');
        expect(results3.tracks.isNotEmpty, true);
      });

      test('should return consistent results for same query', () async {
        // Act
        final results1 = await repository.getSearchResults('Weeknd');
        final results2 = await repository.getSearchResults('Weeknd');

        // Assert
        expect(results1.tracks.length, results2.tracks.length);
      });
    });
  });
}

// ==================== Mock Classes ====================
class MockSearchRepository implements SearchRepository {
  List<SearchSuggestion> mockSuggestions = [];
  SearchResults mockResults = const SearchResults(tracks: []);

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    return mockSuggestions;
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    return mockResults;
  }
}
