import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/search/data/datasources/search_remote_datasource.dart';
import 'package:rythmify/features/search/domain/entities/top_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SearchRemoteSourceImpl dataSource;
  late RequestOptions? lastRequest;
  late Object? nextResponseData;
  late DioException? nextException;

  void respondWith(Map<String, dynamic> data) {
    nextResponseData = data;
    nextException = null;
  }

  void throwNext() {
    nextException = DioException(
      requestOptions: RequestOptions(path: ''),
      message: 'Network error',
    );
  }

  setUp(() {
    lastRequest = null;
    nextResponseData = {'data': <String, dynamic>{}};
    nextException = null;

    apiClient.dio.interceptors.clear();
    apiClient.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
          final exception = nextException;
          if (exception != null) {
            return handler.reject(exception);
          }

          return handler.resolve(
            Response(
              requestOptions: options,
              data: nextResponseData,
              statusCode: 200,
            ),
          );
        },
      ),
    );

    dataSource = SearchRemoteSourceImpl();
  });

  group('SearchRemoteSourceImpl - getSuggestions', () {
    test(
      'returns user and track suggestions when API call is successful',
      () async {
        respondWith({
          'data': {
            'suggestions': ['song one', 'song two'],
            'users': [
              {
                'id': 'user-1',
                'display_name': 'John Doe',
                'profile_picture': 'https://example.com/avatar.jpg',
              },
            ],
          },
        });

        final result = await dataSource.getSuggestions('test');

        expect(result.length, 3);
        expect(result[0].id, 'user-1');
        expect(result[0].text, 'John Doe');
        expect(result[0].type, 'user');
        expect(result[0].avatarUrl, 'https://example.com/avatar.jpg');
        expect(result[1].id, '0');
        expect(result[1].text, 'song one');
        expect(result[1].type, 'track');
        expect(result[2].id, '1');
        expect(result[2].text, 'song two');
        expect(result[2].type, 'track');
      },
    );

    test('returns empty list when suggestions and users are null', () async {
      respondWith({
        'data': {'suggestions': null, 'users': null},
      });

      final result = await dataSource.getSuggestions('test');

      expect(result, isEmpty);
    });

    test(
      'returns user suggestions without avatar when profile picture is null',
      () async {
        respondWith({
          'data': {
            'suggestions': [],
            'users': [
              {
                'id': 'user-1',
                'display_name': 'Jane Doe',
                'profile_picture': null,
              },
            ],
          },
        });

        final result = await dataSource.getSuggestions('test');

        expect(result.length, 1);
        expect(result[0].id, 'user-1');
        expect(result[0].text, 'Jane Doe');
        expect(result[0].type, 'user');
        expect(result[0].avatarUrl, isNull);
      },
    );

    test('uses empty display name when user display_name is null', () async {
      respondWith({
        'data': {
          'suggestions': [],
          'users': [
            {'id': 'user-1', 'display_name': null},
          ],
        },
      });

      final result = await dataSource.getSuggestions('test');

      expect(result[0].text, '');
    });

    test('makes correct API call with query parameter', () async {
      await dataSource.getSuggestions('my search query');

      expect(lastRequest?.path, '/suggestions');
      expect(lastRequest?.queryParameters, {'q': 'my search query'});
    });

    test('throws exception when API call fails', () async {
      throwNext();

      expect(
        () => dataSource.getSuggestions('test'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('SearchRemoteSourceImpl - getSearchResultsTyped', () {
    test('returns SearchResults with tracks when type is tracks', () async {
      respondWith({
        'data': {
          'tracks': [
            {
              'id': 'track-1',
              'title': 'Test Track',
              'artist_name': 'Test Artist',
              'duration': 180,
              'stream_url': 'https://example.com/audio.mp3',
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'tracks');

      expect(result.tracks.length, 1);
      expect(result.tracks[0].id, 'track-1');
      expect(result.tracks[0].title, 'Test Track');
      expect(result.tracks[0].artist, 'Test Artist');
      expect(result.tracks[0].duration.inSeconds, 180);
    });

    test('returns SearchResults with profiles when type is users', () async {
      respondWith({
        'data': {
          'users': [
            {
              'id': 'user-1',
              'display_name': 'Test User',
              'username': 'testuser',
              'profile_picture': 'https://example.com/avatar.jpg',
              'follower_count': 100,
              'is_following': true,
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'users');

      expect(result.profiles.length, 1);
      expect(result.profiles[0].id, 'user-1');
      expect(result.profiles[0].displayName, 'Test User');
      expect(result.profiles[0].username, 'testuser');
      expect(result.profiles[0].avatarUrl, 'https://example.com/avatar.jpg');
      expect(result.profiles[0].followersCount, 100);
      expect(result.profiles[0].isFollowing, true);
    });

    test(
      'returns SearchResults with playlists when type is playlists',
      () async {
        respondWith({
          'data': {
            'playlists': [
              {
                'id': 'playlist-1',
                'title': 'Test Playlist',
                'owner': {'display_name': 'Owner Name'},
                'track_count': 10,
                'cover_image': 'https://example.com/cover.jpg',
                'preview_tracks': [],
              },
            ],
          },
        });

        final result = await dataSource.getSearchResultsTyped(
          'test',
          'playlists',
        );

        expect(result.playlists.length, 1);
        expect(result.playlists[0]['id'], 'playlist-1');
        expect(result.playlists[0]['title'], 'Test Playlist');
        expect(result.playlists[0]['creator'], 'Owner Name');
        expect(result.playlists[0]['trackCount'], '10');
        expect(
          result.playlists[0]['artworkUrl'],
          'https://example.com/cover.jpg',
        );
      },
    );

    test('returns SearchResults with albums when type is albums', () async {
      respondWith({
        'data': {
          'albums': [
            {
              'id': 'album-1',
              'title': 'Test Album',
              'owner': {'display_name': 'Artist Name'},
              'cover_image': 'https://example.com/cover.jpg',
              'release_date': '2024-01-15',
              'subtype': 'LP',
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'albums');

      expect(result.albums.length, 1);
      expect(result.albums[0]['id'], 'album-1');
      expect(result.albums[0]['title'], 'Test Album');
      expect(result.albums[0]['artist'], 'Artist Name');
      expect(result.albums[0]['artworkUrl'], 'https://example.com/cover.jpg');
      expect(result.albums[0]['year'], '2024');
      expect(result.albums[0]['type'], 'LP');
    });

    test(
      'returns empty lists when response data has no result lists',
      () async {
        final result = await dataSource.getSearchResultsTyped('test', 'tracks');

        expect(result.tracks, isEmpty);
        expect(result.profiles, isEmpty);
        expect(result.playlists, isEmpty);
        expect(result.albums, isEmpty);
      },
    );

    test('handles playlist with null owner and preview artwork', () async {
      respondWith({
        'data': {
          'playlists': [
            {
              'id': 'playlist-1',
              'title': 'Test Playlist',
              'owner': null,
              'track_count': 5,
              'cover_image': null,
              'preview_tracks': [
                {'cover_image': 'https://example.com/preview.jpg'},
              ],
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped(
        'test',
        'playlists',
      );

      expect(result.playlists[0]['creator'], '');
      expect(
        result.playlists[0]['artworkUrl'],
        'https://example.com/preview.jpg',
      );
    });

    test('handles album fallbacks', () async {
      respondWith({
        'data': {
          'albums': [
            {
              'id': 'album-1',
              'title': 'Test Album',
              'owner': {'display_name': 'Artist'},
              'cover_image': null,
              'release_date': '',
              'subtype': null,
              'preview_tracks': [
                {'cover_image': 'https://example.com/preview.jpg'},
              ],
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'albums');

      expect(result.albums[0]['year'], '');
      expect(result.albums[0]['type'], 'Album');
      expect(result.albums[0]['artworkUrl'], 'https://example.com/preview.jpg');
    });

    test('maps alternate track artist and genre fields', () async {
      respondWith({
        'data': {
          'tracks': [
            {
              'id': 'track-1',
              'title': 'Test Track',
              'artist': 'Direct Artist',
              'genre_name': 'Jazz',
              'duration': 180,
              'stream_url': 'https://example.com/audio.mp3',
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'tracks');

      expect(result.tracks[0].artist, 'Direct Artist');
      expect(result.tracks[0].genre, 'Jazz');
    });

    test('handles profile with null username gracefully', () async {
      respondWith({
        'data': {
          'users': [
            {
              'id': 'user-1',
              'display_name': 'Test User',
              'username': null,
              'profile_picture': null,
              'follower_count': 0,
              'is_following': false,
            },
          ],
        },
      });

      final result = await dataSource.getSearchResultsTyped('test', 'users');

      expect(result.profiles[0].username, isNull);
    });

    test('makes correct API call with query and type parameters', () async {
      await dataSource.getSearchResultsTyped('my search', 'tracks');

      expect(lastRequest?.path, '/search');
      expect(lastRequest?.queryParameters, {
        'q': 'my search',
        'type': 'tracks',
      });
    });

    test('throws exception when API call fails', () async {
      throwNext();

      expect(
        () => dataSource.getSearchResultsTyped('test', 'tracks'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('SearchRemoteSourceImpl - getSearchResults', () {
    test(
      'returns combined search results and top user when user score wins',
      () async {
        respondWith({
          'data': {
            'tracks': [
              {
                'id': 'track-1',
                'title': 'Test Track',
                'artist_name': 'Test Artist',
                'genre_name': 'Pop',
                'duration': 180,
                'stream_url': 'https://example.com/audio.mp3',
              },
            ],
            'users': [
              {
                'id': 'user-1',
                'display_name': 'Test User',
                'username': 'testuser',
                'profile_picture': 'https://example.com/avatar.jpg',
                'follower_count': 100,
                'is_following': true,
              },
            ],
            'playlists': [
              {
                'id': 'playlist-1',
                'title': 'Test Playlist',
                'owner': {'display_name': 'Owner Name'},
                'track_count': 10,
                'cover_image': null,
                'preview_tracks': [
                  {'cover_image': 'https://example.com/playlist-preview.jpg'},
                ],
              },
            ],
            'albums': [
              {
                'id': 'album-1',
                'title': 'Test Album',
                'owner': {'display_name': 'Artist Name'},
                'cover_image': null,
                'release_date': '2024-01-15',
                'subtype': 'LP',
                'preview_tracks': [
                  {'cover_image': 'https://example.com/album-preview.jpg'},
                ],
              },
            ],
            'top_track': {
              'id': 'top-track',
              'title': 'Top Track',
              'artist_name': 'Top Artist',
              'duration': 200,
              'stream_url': 'https://example.com/top.mp3',
              'score': 0.2,
            },
            'top_user': {
              'id': 'top-user',
              'display_name': 'Top User',
              'username': 'topuser',
              'profile_picture': 'https://example.com/top.jpg',
              'follower_count': 500,
              'is_following': false,
              'score': 0.9,
            },
          },
        });

        final result = await dataSource.getSearchResults('test');

        expect(lastRequest?.path, '/search');
        expect(lastRequest?.queryParameters, {
          'q': 'test',
          'type': 'everything',
        });
        expect(result.tracks.single.artist, 'Test Artist');
        expect(result.tracks.single.genre, 'Pop');
        expect(result.profiles.single.displayName, 'Test User');
        expect(
          result.playlists.single['artworkUrl'],
          'https://example.com/playlist-preview.jpg',
        );
        expect(
          result.albums.single['artworkUrl'],
          'https://example.com/album-preview.jpg',
        );
        expect(result.albums.single['year'], '2024');
        expect(result.topResult, isA<TopResultUser>());
        expect(
          (result.topResult as TopResultUser).profile.displayName,
          'Top User',
        );
      },
    );

    test('returns top track when track score wins', () async {
      respondWith({
        'data': {
          'tracks': [],
          'users': [],
          'playlists': [],
          'albums': [],
          'top_track': {
            'id': 'top-track',
            'title': 'Top Track',
            'artist_name': 'Top Artist',
            'genre_name': 'Rock',
            'duration': 200,
            'stream_url': 'https://example.com/top.mp3',
            'score': 0.9,
          },
          'top_user': {
            'id': 'top-user',
            'display_name': 'Top User',
            'score': 0.1,
          },
        },
      });

      final result = await dataSource.getSearchResults('test');

      expect(result.topResult, isA<TopResultTrack>());
      final topTrack = result.topResult as TopResultTrack;
      expect(topTrack.track.id, 'top-track');
      expect(topTrack.track.artist, 'Top Artist');
      expect(topTrack.track.genre, 'Rock');
    });

    test(
      'returns empty result groups and null top result when data lists are missing',
      () async {
        final result = await dataSource.getSearchResults('empty');

        expect(result.tracks, isEmpty);
        expect(result.profiles, isEmpty);
        expect(result.playlists, isEmpty);
        expect(result.albums, isEmpty);
        expect(result.topResult, isNull);
      },
    );

    test(
      'uses fallback values for null playlist, album, and profile fields',
      () async {
        respondWith({
          'data': {
            'tracks': [],
            'users': [
              {
                'id': 'user-1',
                'display_name': null,
                'username': null,
                'profile_picture': null,
                'follower_count': null,
                'is_following': null,
              },
            ],
            'playlists': [
              {
                'id': null,
                'title': null,
                'owner': null,
                'track_count': null,
                'cover_image': null,
                'preview_tracks': [],
              },
            ],
            'albums': [
              {
                'id': null,
                'title': null,
                'owner': null,
                'cover_image': null,
                'release_date': '',
                'subtype': null,
                'preview_tracks': [],
              },
            ],
          },
        });

        final result = await dataSource.getSearchResults('fallbacks');

        expect(result.profiles.single.displayName, '');
        expect(result.profiles.single.followersCount, 0);
        expect(result.profiles.single.isFollowing, false);
        expect(result.playlists.single['id'], '');
        expect(result.playlists.single['title'], '');
        expect(result.playlists.single['creator'], '');
        expect(result.playlists.single['trackCount'], '0');
        expect(result.playlists.single['artworkUrl'], '');
        expect(result.albums.single['id'], '');
        expect(result.albums.single['title'], '');
        expect(result.albums.single['artist'], '');
        expect(result.albums.single['artworkUrl'], '');
        expect(result.albums.single['year'], '');
        expect(result.albums.single['type'], 'Album');
      },
    );

    test('throws exception when API call fails', () async {
      throwNext();

      expect(
        () => dataSource.getSearchResults('test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
