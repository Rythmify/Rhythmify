import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';

void main() {
  group('SearchSuggestion', () {
    test('creates instance with required parameters', () {
      const suggestion = SearchSuggestion(
        id: '1',
        text: 'Test Song',
        type: 'track',
      );

      expect(suggestion.id, '1');
      expect(suggestion.text, 'Test Song');
      expect(suggestion.type, 'track');
      expect(suggestion.avatarUrl, isNull);
    });

    test('creates instance with all parameters', () {
      const suggestion = SearchSuggestion(
        id: '1',
        text: 'Test User',
        type: 'user',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(suggestion.id, '1');
      expect(suggestion.text, 'Test User');
      expect(suggestion.type, 'user');
      expect(suggestion.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('supports different types', () {
      const trackSuggestion = SearchSuggestion(
        id: '1',
        text: 'Track',
        type: 'track',
      );
      const userSuggestion = SearchSuggestion(
        id: '2',
        text: 'User',
        type: 'user',
      );
      const playlistSuggestion = SearchSuggestion(
        id: '3',
        text: 'Playlist',
        type: 'playlist',
      );
      const albumSuggestion = SearchSuggestion(
        id: '4',
        text: 'Album',
        type: 'album',
      );

      expect(trackSuggestion.type, 'track');
      expect(userSuggestion.type, 'user');
      expect(playlistSuggestion.type, 'playlist');
      expect(albumSuggestion.type, 'album');
    });

    test('handles empty strings', () {
      const suggestion = SearchSuggestion(id: '', text: '', type: '');

      expect(suggestion.id, '');
      expect(suggestion.text, '');
      expect(suggestion.type, '');
    });

    test('handles null avatarUrl', () {
      const suggestion = SearchSuggestion(
        id: '1',
        text: 'Test',
        type: 'track',
        avatarUrl: null,
      );

      expect(suggestion.avatarUrl, isNull);
    });
  });
}
