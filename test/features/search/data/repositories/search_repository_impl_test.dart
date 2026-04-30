import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/search/data/datasources/search_remote_datasource.dart';
import 'package:rythmify/features/search/data/repositories/search_repository_impl.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

class MockSearchRemoteSource extends Mock implements SearchRemoteSource {}

void main() {
  late SearchRepositoryImpl repository;
  late MockSearchRemoteSource mockRemoteSource;

  setUp(() {
    mockRemoteSource = MockSearchRemoteSource();
    repository = SearchRepositoryImpl(remoteSource: mockRemoteSource);
  });

  setUpAll(() {
    registerFallbackValue(const SearchResults(tracks: []));
    registerFallbackValue(<SearchSuggestion>[]);
  });

  group('SearchRepositoryImpl', () {
    group('getSuggestions', () {
      test('delegates to remote source and returns suggestions', () async {
        final tSuggestions = [
          const SearchSuggestion(id: '1', text: 'song one', type: 'track'),
          const SearchSuggestion(id: '2', text: 'song two', type: 'track'),
        ];

        when(
          () => mockRemoteSource.getSuggestions(any()),
        ).thenAnswer((_) async => tSuggestions);

        final result = await repository.getSuggestions('test query');

        expect(result, tSuggestions);
        verify(() => mockRemoteSource.getSuggestions('test query')).called(1);
      });

      test('propagates exception when remote source fails', () async {
        when(
          () => mockRemoteSource.getSuggestions(any()),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.getSuggestions('test'), throwsException);
      });

      test('returns empty list when no suggestions found', () async {
        when(
          () => mockRemoteSource.getSuggestions(any()),
        ).thenAnswer((_) async => []);

        final result = await repository.getSuggestions('xyz');

        expect(result, isEmpty);
        verify(() => mockRemoteSource.getSuggestions('xyz')).called(1);
      });
    });

    group('getSearchResults', () {
      test('delegates to remote source and returns results', () async {
        final tResults = SearchResults(
          tracks: [
            Track(
              id: 'track-1',
              userId: 'user-1',
              title: 'Test Track',
              artist: 'Test Artist',
              audioUrl: 'https://example.com/audio.mp3',
              duration: Duration(seconds: 180),
              createdAt: DateTime(2024, 1, 1),
            ),
          ],
        );

        when(
          () => mockRemoteSource.getSearchResults(any()),
        ).thenAnswer((_) async => tResults);

        final result = await repository.getSearchResults('test query');

        expect(result, tResults);
        verify(() => mockRemoteSource.getSearchResults('test query')).called(1);
      });

      test('propagates exception when remote source fails', () async {
        when(
          () => mockRemoteSource.getSearchResults(any()),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.getSearchResults('test'), throwsException);
      });
    });

    group('getSearchResultsTyped', () {
      test('delegates to remote source with type parameter', () async {
        final tResults = SearchResults(
          tracks: [],
          profiles: [
            const ProfileEntity(
              id: 'user-1',
              displayName: 'Test User',
              username: 'testuser',
            ),
          ],
        );

        when(
          () => mockRemoteSource.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => tResults);

        final result = await repository.getSearchResultsTyped('test', 'users');

        expect(result, tResults);
        expect(result.profiles.length, 1);
        verify(
          () => mockRemoteSource.getSearchResultsTyped('test', 'users'),
        ).called(1);
      });

      test('propagates exception when remote source fails', () async {
        when(
          () => mockRemoteSource.getSearchResultsTyped(any(), any()),
        ).thenThrow(Exception('Network error'));

        expect(
          () => repository.getSearchResultsTyped('test', 'tracks'),
          throwsException,
        );
      });

      test('returns empty results for unknown type', () async {
        final tResults = const SearchResults(tracks: []);

        when(
          () => mockRemoteSource.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => tResults);

        final result = await repository.getSearchResultsTyped(
          'test',
          'unknown',
        );

        expect(result.tracks, isEmpty);
        expect(result.profiles, isEmpty);
        expect(result.playlists, isEmpty);
        expect(result.albums, isEmpty);
      });
    });
  });
}
