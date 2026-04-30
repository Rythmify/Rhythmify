import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/datasources/search_mock_datasource.dart';

void main() {
  group('SearchRemoteSourceMock', () {
    late SearchRemoteSourceMock source;

    setUp(() {
      source = SearchRemoteSourceMock();
    });

    test('filters suggestions by trimmed lowercase prefix', () async {
      final suggestions = await source.getSuggestions('  the  ');

      expect(suggestions, hasLength(1));
      expect(suggestions.single.text, 'The Weeknd');
      expect(suggestions.single.type, 'user');
    });

    test('returns full search results matching query across groups', () async {
      final results = await source.getSearchResults('weeknd');

      expect(results.tracks.map((track) => track.title), contains('Starboy'));
      expect(results.profiles.map((profile) => profile.displayName), [
        'The Weeknd',
      ]);
      expect(
        results.albums.map((album) => album['title']),
        contains('After Hours'),
      );
      expect(results.playlists, isEmpty);
    });

    test('returns only requested typed tracks', () async {
      final results = await source.getSearchResultsTyped('weeknd', 'tracks');

      expect(results.tracks, isNotEmpty);
      expect(results.profiles, isEmpty);
      expect(results.playlists, isEmpty);
      expect(results.albums, isEmpty);
    });

    test('returns only requested typed users', () async {
      final results = await source.getSearchResultsTyped('billie', 'users');

      expect(results.tracks, isEmpty);
      expect(results.profiles.single.displayName, 'Billie Eilish');
      expect(results.playlists, isEmpty);
      expect(results.albums, isEmpty);
    });

    test('returns only requested typed playlists', () async {
      final results = await source.getSearchResultsTyped('lo-fi', 'playlists');

      expect(results.tracks, isEmpty);
      expect(results.profiles, isEmpty);
      expect(results.playlists.single['title'], 'Lo-Fi Beats');
      expect(results.albums, isEmpty);
    });

    test('returns only requested typed albums', () async {
      final results = await source.getSearchResultsTyped('divide', 'albums');

      expect(results.tracks, isEmpty);
      expect(results.profiles, isEmpty);
      expect(results.playlists, isEmpty);
      expect(results.albums.single['artist'], 'Ed Sheeran');
    });
  });
}
