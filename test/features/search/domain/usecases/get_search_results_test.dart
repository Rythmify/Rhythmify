import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/features/search/domain/repositories/search_repository.dart';
import 'package:rythmify/features/search/domain/usecases/get_search_results.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late GetSearchResults useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = GetSearchResults(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const SearchResults(tracks: []));
  });

  group('GetSearchResults', () {
    group('call (getSearchResults)', () {
      test('returns SearchResults from repository', () async {
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
          profiles: const [
            ProfileEntity(
              id: 'user-1',
              displayName: 'Test User',
              username: 'testuser',
            ),
          ],
        );

        when(
          () => mockRepository.getSearchResults(any()),
        ).thenAnswer((_) async => tResults);

        final result = await useCase.call('test');

        expect(result, tResults);
        expect(result.tracks.length, 1);
        expect(result.profiles.length, 1);
        verify(() => mockRepository.getSearchResults('test')).called(1);
      });

      test('returns empty SearchResults when no results found', () async {
        when(
          () => mockRepository.getSearchResults(any()),
        ).thenAnswer((_) async => const SearchResults(tracks: []));

        final result = await useCase.call('xyz');

        expect(result.tracks, isEmpty);
        expect(result.profiles, isEmpty);
        verify(() => mockRepository.getSearchResults('xyz')).called(1);
      });

      test('propagates exception from repository', () async {
        when(
          () => mockRepository.getSearchResults(any()),
        ).thenThrow(Exception('Network error'));

        expect(() => useCase.call('test'), throwsException);
      });

      test('passes query to repository correctly', () async {
        when(
          () => mockRepository.getSearchResults(any()),
        ).thenAnswer((_) async => const SearchResults(tracks: []));

        await useCase.call('my search query');

        verify(
          () => mockRepository.getSearchResults('my search query'),
        ).called(1);
      });
    });

    group('callTyped (getSearchResultsTyped)', () {
      test('returns SearchResults with tracks when type is tracks', () async {
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
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => tResults);

        final result = await useCase.callTyped('test', 'tracks');

        expect(result.tracks.length, 1);
        verify(
          () => mockRepository.getSearchResultsTyped('test', 'tracks'),
        ).called(1);
      });

      test('returns SearchResults with profiles when type is users', () async {
        final tResults = SearchResults(
          tracks: const [],
          profiles: const [
            ProfileEntity(
              id: 'user-1',
              displayName: 'Test User',
              username: 'testuser',
            ),
          ],
        );

        when(
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => tResults);

        final result = await useCase.callTyped('test', 'users');

        expect(result.profiles.length, 1);
        verify(
          () => mockRepository.getSearchResultsTyped('test', 'users'),
        ).called(1);
      });

      test(
        'returns SearchResults with playlists when type is playlists',
        () async {
          final tResults = SearchResults(
            tracks: const [],
            playlists: const [
              {'id': 'playlist-1', 'title': 'Test Playlist'},
            ],
          );

          when(
            () => mockRepository.getSearchResultsTyped(any(), any()),
          ).thenAnswer((_) async => tResults);

          final result = await useCase.callTyped('test', 'playlists');

          expect(result.playlists.length, 1);
          verify(
            () => mockRepository.getSearchResultsTyped('test', 'playlists'),
          ).called(1);
        },
      );

      test('returns SearchResults with albums when type is albums', () async {
        final tResults = SearchResults(
          tracks: const [],
          albums: const [
            {'id': 'album-1', 'title': 'Test Album'},
          ],
        );

        when(
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => tResults);

        final result = await useCase.callTyped('test', 'albums');

        expect(result.albums.length, 1);
        verify(
          () => mockRepository.getSearchResultsTyped('test', 'albums'),
        ).called(1);
      });

      test('propagates exception from repository', () async {
        when(
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenThrow(Exception('Network error'));

        expect(() => useCase.callTyped('test', 'tracks'), throwsException);
      });

      test('passes query and type to repository correctly', () async {
        when(
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => const SearchResults(tracks: []));

        await useCase.callTyped('my search', 'tracks');

        verify(
          () => mockRepository.getSearchResultsTyped('my search', 'tracks'),
        ).called(1);
      });

      test('handles all type variations', () async {
        when(
          () => mockRepository.getSearchResultsTyped(any(), any()),
        ).thenAnswer((_) async => const SearchResults(tracks: []));

        await useCase.callTyped('test', 'all');

        verify(
          () => mockRepository.getSearchResultsTyped('test', 'all'),
        ).called(1);
      });
    });
  });
}
