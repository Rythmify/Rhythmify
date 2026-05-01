import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/domain/entities/top_result.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('TopResult', () {
    group('TopResultTrack', () {
      test('creates instance with Track', () {
        final track = Track(
          id: 'track-1',
          userId: 'user-1',
          title: 'Top Track',
          artist: 'Top Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: Duration(seconds: 180),
          createdAt: DateTime(2024, 1, 1),
        );

        final topResult = TopResultTrack(track);

        expect(topResult, isA<TopResultTrack>());
        expect(topResult.track.id, 'track-1');
        expect(topResult.track.title, 'Top Track');
      });

      test('holds correct track data', () {
        final track = Track(
          id: 'track-123',
          userId: 'user-456',
          title: 'Test Title',
          artist: 'Test Artist',
          audioUrl: 'https://example.com/test.mp3',
          duration: Duration(seconds: 240),
          createdAt: DateTime(2024, 1, 1),
        );

        final topResult = TopResultTrack(track);

        expect(topResult.track.id, 'track-123');
        expect(topResult.track.userId, 'user-456');
        expect(topResult.track.title, 'Test Title');
        expect(topResult.track.artist, 'Test Artist');
        expect(topResult.track.audioUrl, 'https://example.com/test.mp3');
        expect(topResult.track.duration.inSeconds, 240);
      });
    });

    group('TopResultUser', () {
      test('creates instance with ProfileEntity', () {
        const profile = ProfileEntity(
          id: 'user-1',
          displayName: 'Top User',
          username: 'topuser',
        );

        final topResult = TopResultUser(profile);

        expect(topResult, isA<TopResultUser>());
        expect(topResult.profile.id, 'user-1');
        expect(topResult.profile.displayName, 'Top User');
      });

      test('holds correct profile data', () {
        const profile = ProfileEntity(
          id: 'user-123',
          displayName: 'Test User',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
          followersCount: 1000,
          isFollowing: true,
        );

        final topResult = TopResultUser(profile);

        expect(topResult.profile.id, 'user-123');
        expect(topResult.profile.displayName, 'Test User');
        expect(topResult.profile.username, 'testuser');
        expect(topResult.profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(topResult.profile.followersCount, 1000);
        expect(topResult.profile.isFollowing, true);
      });
    });

    group('TopResultPlaylist', () {
      test('creates instance with playlist map', () {
        final playlist = <String, String>{
          'id': 'playlist-1',
          'title': 'Top Playlist',
          'creator': 'User',
          'trackCount': '15',
          'artworkUrl': 'https://example.com/cover.jpg',
        };

        final topResult = TopResultPlaylist(playlist);

        expect(topResult, isA<TopResultPlaylist>());
        expect(topResult.playlist['id'], 'playlist-1');
        expect(topResult.playlist['title'], 'Top Playlist');
      });

      test('holds correct playlist data', () {
        final playlist = <String, String>{
          'id': 'playlist-123',
          'title': 'My Playlist',
          'creator': 'Creator Name',
          'trackCount': '25',
          'artworkUrl': 'https://example.com/art.jpg',
        };

        final topResult = TopResultPlaylist(playlist);

        expect(topResult.playlist['id'], 'playlist-123');
        expect(topResult.playlist['title'], 'My Playlist');
        expect(topResult.playlist['creator'], 'Creator Name');
        expect(topResult.playlist['trackCount'], '25');
        expect(topResult.playlist['artworkUrl'], 'https://example.com/art.jpg');
      });

      test('handles empty playlist map', () {
        final playlist = <String, String>{};

        final topResult = TopResultPlaylist(playlist);

        expect(topResult.playlist, isEmpty);
      });
    });

    group('TopResultAlbum', () {
      test('creates instance with album map', () {
        final album = <String, String>{
          'id': 'album-1',
          'title': 'Top Album',
          'artist': 'Artist',
          'artworkUrl': 'https://example.com/cover.jpg',
          'year': '2024',
          'type': 'LP',
        };

        final topResult = TopResultAlbum(album);

        expect(topResult, isA<TopResultAlbum>());
        expect(topResult.album['id'], 'album-1');
        expect(topResult.album['title'], 'Top Album');
      });

      test('holds correct album data', () {
        final album = <String, String>{
          'id': 'album-123',
          'title': 'My Album',
          'artist': 'Album Artist',
          'artworkUrl': 'https://example.com/art.jpg',
          'year': '2023',
          'type': 'EP',
        };

        final topResult = TopResultAlbum(album);

        expect(topResult.album['id'], 'album-123');
        expect(topResult.album['title'], 'My Album');
        expect(topResult.album['artist'], 'Album Artist');
        expect(topResult.album['artworkUrl'], 'https://example.com/art.jpg');
        expect(topResult.album['year'], '2023');
        expect(topResult.album['type'], 'EP');
      });

      test('handles empty album map', () {
        final album = <String, String>{};

        final topResult = TopResultAlbum(album);

        expect(topResult.album, isEmpty);
      });
    });

    group('sealed class behavior', () {
      test('can use sealed class in switch expression', () {
        final track = Track(
          id: 'track-1',
          userId: 'user-1',
          title: 'Test',
          artist: 'Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: Duration(seconds: 180),
          createdAt: DateTime(2024, 1, 1),
        );

        const profile = ProfileEntity(id: 'user-1', displayName: 'Test User');

        final playlist = <String, String>{'id': '1', 'title': 'Test'};
        final album = <String, String>{'id': '1', 'title': 'Test'};

        final results = [
          TopResultTrack(track),
          TopResultUser(profile),
          TopResultPlaylist(playlist),
          TopResultAlbum(album),
        ];

        final types = results
            .map(
              (r) => switch (r) {
                TopResultTrack() => 'track',
                TopResultUser() => 'user',
                TopResultPlaylist() => 'playlist',
                TopResultAlbum() => 'album',
              },
            )
            .toList();

        expect(types, ['track', 'user', 'playlist', 'album']);
      });

      test('exhaustiveness check - all cases handled', () {
        void handleResult(TopResult result) {
          switch (result) {
            case TopResultTrack():
            // Handle track
            case TopResultUser():
            // Handle user
            case TopResultPlaylist():
            // Handle playlist
            case TopResultAlbum():
            // Handle album
          }
        }

        final track = Track(
          id: 'track-1',
          userId: 'user-1',
          title: 'Test',
          artist: 'Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: Duration(seconds: 180),
          createdAt: DateTime(2024, 1, 1),
        );

        // This should compile without warnings if all cases are handled
        handleResult(TopResultTrack(track));
      });
    });
  });
}
