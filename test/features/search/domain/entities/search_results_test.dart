import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/domain/entities/search_results.dart';
import 'package:rythmify/features/search/domain/entities/top_result.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('SearchResults', () {
    test('creates instance with required parameters', () {
      final results = SearchResults(
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

      expect(results.tracks.length, 1);
      expect(results.tracks[0].id, 'track-1');
    });

    test('creates instance with all parameters', () {
      final results = SearchResults(
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
        playlists: const [
          {'id': 'playlist-1', 'title': 'Test Playlist'},
        ],
        albums: const [
          {'id': 'album-1', 'title': 'Test Album'},
        ],
        topResult: TopResultTrack(
          Track(
            id: 'top-track',
            userId: 'user-1',
            title: 'Top Track',
            artist: 'Top Artist',
            audioUrl: 'https://example.com/audio.mp3',
            duration: Duration(seconds: 180),
            createdAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(results.tracks.length, 1);
      expect(results.profiles.length, 1);
      expect(results.playlists.length, 1);
      expect(results.albums.length, 1);
      expect(results.topResult, isA<TopResultTrack>());
    });

    test('defaults to empty lists when not provided', () {
      const results = SearchResults(tracks: []);

      expect(results.tracks, isEmpty);
      expect(results.profiles, isEmpty);
      expect(results.playlists, isEmpty);
      expect(results.albums, isEmpty);
      expect(results.topResult, isNull);
    });

    test('handles empty tracks list', () {
      const results = SearchResults(tracks: []);

      expect(results.tracks, isEmpty);
    });

    test('handles empty profiles list', () {
      const results = SearchResults(tracks: [], profiles: []);

      expect(results.profiles, isEmpty);
    });

    test('handles empty playlists list', () {
      const results = SearchResults(tracks: [], playlists: []);

      expect(results.playlists, isEmpty);
    });

    test('handles empty albums list', () {
      const results = SearchResults(tracks: [], albums: []);

      expect(results.albums, isEmpty);
    });

    test('handles null topResult', () {
      const results = SearchResults(tracks: [], topResult: null);

      expect(results.topResult, isNull);
    });

    test('supports playlist as Map<String, String>', () {
      const results = SearchResults(
        tracks: [],
        playlists: [
          {
            'id': 'playlist-1',
            'title': 'My Playlist',
            'creator': 'User',
            'trackCount': '10',
            'artworkUrl': 'https://example.com/cover.jpg',
          },
        ],
      );

      expect(results.playlists[0]['id'], 'playlist-1');
      expect(results.playlists[0]['title'], 'My Playlist');
      expect(results.playlists[0]['creator'], 'User');
      expect(results.playlists[0]['trackCount'], '10');
      expect(
        results.playlists[0]['artworkUrl'],
        'https://example.com/cover.jpg',
      );
    });

    test('supports album as Map<String, String>', () {
      const results = SearchResults(
        tracks: [],
        albums: [
          {
            'id': 'album-1',
            'title': 'My Album',
            'artist': 'Artist',
            'artworkUrl': 'https://example.com/cover.jpg',
            'year': '2024',
            'type': 'LP',
          },
        ],
      );

      expect(results.albums[0]['id'], 'album-1');
      expect(results.albums[0]['title'], 'My Album');
      expect(results.albums[0]['artist'], 'Artist');
      expect(results.albums[0]['year'], '2024');
      expect(results.albums[0]['type'], 'LP');
    });

    test('handles multiple tracks', () {
      final results = SearchResults(
        tracks: [
          Track(
            id: 'track-1',
            userId: 'user-1',
            title: 'Track 1',
            artist: 'Artist 1',
            audioUrl: 'https://example.com/audio1.mp3',
            duration: Duration(seconds: 180),
            createdAt: DateTime(2024, 1, 1),
          ),
          Track(
            id: 'track-2',
            userId: 'user-2',
            title: 'Track 2',
            artist: 'Artist 2',
            audioUrl: 'https://example.com/audio2.mp3',
            duration: Duration(seconds: 200),
            createdAt: DateTime(2024, 1, 2),
          ),
        ],
      );

      expect(results.tracks.length, 2);
    });

    test('handles multiple profiles', () {
      const results = SearchResults(
        tracks: [],
        profiles: [
          ProfileEntity(id: 'user-1', displayName: 'User 1', username: 'user1'),
          ProfileEntity(id: 'user-2', displayName: 'User 2', username: 'user2'),
        ],
      );

      expect(results.profiles.length, 2);
    });
  });
}
