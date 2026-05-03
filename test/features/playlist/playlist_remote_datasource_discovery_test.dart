import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/data/local/local_saved_store.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(
  String path,
  Map<String, dynamic> data,
) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

DioException _dioError(String path, [int statusCode = 500]) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: {
        'error': {'message': 'failed'},
      },
    ),
  );
}

Map<String, dynamic> _playlistJson({
  String id = 'playlist-1',
  String name = 'Playlist',
  String subtype = 'playlist',
  String? ownerId = 'owner-1',
  bool isLiked = false,
}) {
  return {
    'playlist_id': id,
    'id': id,
    'name': name,
    'owner_user_id': ownerId,
    'display_name': 'Owner',
    'is_public': true,
    'type': 'regular',
    'subtype': subtype,
    'track_count': 2,
    'duration': 120,
    'created_at': '2024-01-01T00:00:00Z',
    'is_liked_by_me': isLiked,
  };
}

Map<String, dynamic> _trackJson(
  String id, {
  String? title,
  String? artistName,
  int duration = 90,
  int playCount = 10,
  bool liked = false,
}) {
  return {
    'id': id,
    'track_id': id,
    'title': title ?? 'Track $id',
    'artist_name': artistName ?? 'Artist $id',
    'duration': duration,
    'play_count': playCount,
    'cover_image': 'cover-$id.jpg',
    'is_liked_by_me': liked,
    'stream_url': 'stream-$id',
    'audio_url': 'audio-$id',
  };
}

void main() {
  late MockDio dio;
  late PlaylistRemoteDatasource datasource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dio = MockDio();
    datasource = PlaylistRemoteDatasource(dio);
  });

  group('liked and user playlist responses', () {
    test(
      'fetchLikedPlaylists enriches generated mix and radio from local cache',
      () async {
        await LocalSavedStore.instance.saveMix(
          SavedMix(
            mixId: 'mix-1',
            title: 'Cached Mix',
            ownerName: 'Rythmify',
            coverUrl: 'cached-mix.jpg',
            trackCount: 24,
            savedAt: DateTime.utc(2024, 1, 1),
          ),
        );
        await LocalSavedStore.instance.saveTrackRadio(
          SavedTrackRadio(
            trackId: 'seed-1',
            playlistId: 'radio-playlist-1',
            title: 'Cached Radio',
            coverUrl: 'cached-radio.jpg',
            trackCount: 18,
            savedAt: DateTime.utc(2024, 1, 2),
          ),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/me/liked-playlists',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/me/liked-playlists', {
            'data': {
              'items': [
                {
                  'id': 'mix-1',
                  'subtype': 'auto_generated',
                  'name': 'Backend Mix',
                  'liked_at': '2024-01-03T00:00:00Z',
                },
                {
                  'playlist_id': 'radio-playlist-1',
                  'subtype': 'playlist',
                  'title': 'Backend Radio',
                  'liked_at': '2024-01-04T00:00:00Z',
                },
              ],
            },
          }),
        );

        final result = await datasource.fetchLikedPlaylists(
          limit: 10,
          offset: 5,
        );

        expect(result.map((p) => p.id), ['mix-1', 'radio-playlist-1']);
        expect(result.first.isGeneratedMix, isTrue);
        expect(result.first.coverUrl, 'cached-mix.jpg');
        expect(result.first.trackCount, 24);
        expect(result.last.isTrackRadio, isTrue);
        expect(result.last.coverUrl, 'cached-radio.jpg');
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/me/liked-playlists',
            queryParameters: {'limit': 10, 'offset': 5},
          ),
        ).called(1);
      },
    );

    test('fetchLikedPlaylists rethrows unauthorized API failures', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/me/liked-playlists',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(_dioError('/me/liked-playlists', 401));

      expect(
        () => datasource.fetchLikedPlaylists(),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'fetchUserPlaylists uses mine query for me and user endpoint otherwise',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((invocation) async {
          final path = invocation.positionalArguments.single as String;
          return _response(path, {
            'data': {
              'items': [
                _playlistJson(id: path.contains('/users/') ? 'other' : 'me'),
              ],
            },
          });
        });

        final mine = await datasource.fetchUserPlaylists(
          userId: 'me',
          limit: 7,
        );
        final other = await datasource.fetchUserPlaylists(userId: 'user-2');

        expect(mine.single.id, 'me');
        expect(other.single.id, 'other');
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists',
            queryParameters: {'limit': 7, 'mine': true, 'filter': 'created'},
          ),
        ).called(1);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/users/user-2/playlists',
            queryParameters: {'limit': 50},
          ),
        ).called(1);
      },
    );
  });

  group('playlist detail and metadata operations', () {
    test(
      'fetchPlaylistDetail resolves current user owner without extra user lookup',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-1',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/playlists/playlist-1', {
            'data': _playlistJson(ownerId: 'current-user'),
          }),
        );

        final playlist = await datasource.fetchPlaylistDetail(
          'playlist-1',
          currentUserId: 'current-user',
          currentUserName: 'Current User',
        );

        expect(playlist.ownerName, 'Current User');
        verifyNever(() => dio.get<Map<String, dynamic>>('/users/current-user'));
      },
    );

    test(
      'fetchPlaylistDetail marks locally saved track radios and skips owner lookup',
      () async {
        await LocalSavedStore.instance.saveTrackRadio(
          SavedTrackRadio(
            trackId: 'seed-1',
            playlistId: 'radio-playlist-1',
            title: 'Saved Radio',
            coverUrl: null,
            trackCount: 10,
            savedAt: DateTime.utc(2024, 1, 1),
          ),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/radio-playlist-1',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/playlists/radio-playlist-1', {
            'data': _playlistJson(id: 'radio-playlist-1', ownerId: 'owner-2'),
          }),
        );

        final playlist = await datasource.fetchPlaylistDetail(
          'radio-playlist-1',
        );

        expect(playlist.isTrackRadio, isTrue);
        expect(playlist.ownerName, '');
        verifyNever(() => dio.get<Map<String, dynamic>>('/users/owner-2'));
      },
    );

    test(
      'fetchPlaylistDetail resolves non-radio owner display name from user endpoint',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-2',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/playlists/playlist-2', {
            'data': _playlistJson(id: 'playlist-2', ownerId: 'owner-2'),
          }),
        );
        when(() => dio.get<Map<String, dynamic>>('/users/owner-2')).thenAnswer(
          (_) async => _response('/users/owner-2', {
            'data': {'username': 'owner-two'},
          }),
        );

        final playlist = await datasource.fetchPlaylistDetail('playlist-2');

        expect(playlist.isTrackRadio, isFalse);
        expect(playlist.ownerName, 'owner-two');
      },
    );

    test(
      'fetchTrackById returns the raw track payload and rethrows failures',
      () async {
        when(() => dio.get<Map<String, dynamic>>('/tracks/track-1')).thenAnswer(
          (_) async =>
              _response('/tracks/track-1', {'data': _trackJson('track-1')}),
        );
        expect(
          await datasource.fetchTrackById('track-1'),
          containsPair('id', 'track-1'),
        );

        when(
          () => dio.get<Map<String, dynamic>>('/tracks/missing'),
        ).thenThrow(_dioError('/tracks/missing', 404));
        expect(
          () => datasource.fetchTrackById('missing'),
          throwsA(isA<DioException>()),
        );
      },
    );

    test(
      'updatePlaylist sends form fields for metadata and remove-cover updates',
      () async {
        when(
          () => dio.patch<Map<String, dynamic>>(
            '/playlists/playlist-1',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => _response('/playlists/playlist-1', {
            'data': _playlistJson(
              id: 'playlist-1',
              name: 'Updated',
              subtype: 'album',
            ),
          }),
        );

        final result = await datasource.updatePlaylist(
          playlistId: 'playlist-1',
          name: 'Updated',
          isPublic: false,
          description: 'desc',
          removeCover: true,
          subtype: 'album',
          releaseDate: '2026-01-01',
          genreId: 'genre-1',
        );

        final formData =
            verify(
                  () => dio.patch<Map<String, dynamic>>(
                    '/playlists/playlist-1',
                    data: captureAny(named: 'data'),
                  ),
                ).captured.single
                as FormData;
        final fields = Map<String, dynamic>.fromEntries(formData.fields);
        expect(result.name, 'Updated');
        expect(result.type, PlaylistType.album);
        expect(fields['name'], 'Updated');
        expect(fields['is_public'], 'false');
        expect(fields['remove_cover_image'], 'true');
        expect(fields['release_date'], '2026-01-01');
        expect(fields['genre_id'], 'genre-1');
      },
    );

    test('updatePlaylist rethrows validation errors from the server', () async {
      when(
        () => dio.patch<Map<String, dynamic>>(
          '/playlists/bad',
          data: any(named: 'data'),
        ),
      ).thenThrow(_dioError('/playlists/bad', 422));

      expect(
        () => datasource.updatePlaylist(playlistId: 'bad', name: ''),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('track, station, mix, and recommendation fetching', () {
    test(
      'fetchRadioTracks parses tracks and returns empty on Dio failure',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/radio-1/radio-tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/playlists/radio-1/radio-tracks', {
            'data': {
              'tracks': [
                _trackJson('track-1', liked: true),
                {'title': 'bad'},
              ],
            },
          }),
        );
        final result = await datasource.fetchRadioTracks(
          'radio-1',
          limit: 3,
          offset: 6,
        );
        expect(result, hasLength(1));
        expect(result.single.id, 'track-1');
        expect(result.single.isLiked, isTrue);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/radio-1/radio-tracks',
            queryParameters: {'limit': 3, 'offset': 6},
          ),
        ).called(1);

        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/radio-fail/radio-tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/playlists/radio-fail/radio-tracks'));
        expect(await datasource.fetchRadioTracks('radio-fail'), isEmpty);
      },
    );

    test(
      'fetchStations reads discovery stations, limits results, and rethrows malformed responses',
      () async {
        when(() => dio.get<Map<String, dynamic>>('/home')).thenAnswer(
          (_) async => _response('/home', {
            'data': {
              'discover_with_stations': [
                {
                  'id': 'station-1',
                  'name': 'One Radio',
                  'seed_artist': {'user_id': 'artist-1', 'display_name': 'One'},
                },
                {
                  'id': 'station-2',
                  'name': 'Two Radio',
                  'seed_artist': {'display_name': 'Two'},
                },
              ],
            },
          }),
        );
        expect(
          (await datasource.fetchStations(limit: 1)).single.id,
          'station-1',
        );

        when(
          () => dio.get<Map<String, dynamic>>('/home'),
        ).thenAnswer((_) async => _response('/home', {'data': {}}));
        expect(() => datasource.fetchStations(), throwsA(isA<TypeError>()));

        when(
          () => dio.get<Map<String, dynamic>>('/home'),
        ).thenThrow(_dioError('/home'));
        expect(() => datasource.fetchStations(), throwsA(isA<DioException>()));
      },
    );

    test(
      'fetchSavedStations parses defaults and returns empty on Dio failure',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/users/me/stations',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/users/me/stations', {
            'data': [
              {
                'artist_id': 'artist-1',
                'artist_name': null,
                'profile_picture': 'artist.jpg',
                'track_count': 4,
                'saved_at': '2024-02-01T00:00:00Z',
              },
            ],
          }),
        );

        final stations = await datasource.fetchSavedStations(
          limit: 2,
          offset: 8,
        );
        expect(stations.single.artistName, 'Unknown Artist');
        expect(stations.single.stationName, 'Unknown Radio');
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/users/me/stations',
            queryParameters: {'limit': 2, 'offset': 8},
          ),
        ).called(1);

        when(
          () => dio.get<Map<String, dynamic>>(
            '/users/me/stations',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/users/me/stations'));
        expect(await datasource.fetchSavedStations(), isEmpty);
      },
    );

    test(
      'fetchStationTracks handles list, map, unexpected, and network shapes',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/home/stations/artist-list/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/home/stations/artist-list/tracks', {
            'data': [_trackJson('track-1')],
          }),
        );
        expect(
          (await datasource.fetchStationTracks('artist-list')).single.id,
          'track-1',
        );

        when(
          () => dio.get<Map<String, dynamic>>(
            '/home/stations/artist-map/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/home/stations/artist-map/tracks', {
            'data': {
              'tracks': [_trackJson('track-2')],
            },
          }),
        );
        expect(
          (await datasource.fetchStationTracks('artist-map')).single.id,
          'track-2',
        );

        when(
          () => dio.get<Map<String, dynamic>>(
            '/home/stations/artist-empty/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async =>
              _response('/home/stations/artist-empty/tracks', {'data': 'bad'}),
        );
        expect(await datasource.fetchStationTracks('artist-empty'), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>(
            '/home/stations/artist-fail/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/home/stations/artist-fail/tracks'));
        expect(await datasource.fetchStationTracks('artist-fail'), isEmpty);
      },
    );

    test(
      'fetchRelatedTracks parses tracks and swallows Dio failures',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/tracks/track-1/related',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/tracks/track-1/related', {
            'data': {
              'tracks': [_trackJson('related-1')],
            },
          }),
        );
        expect(
          (await datasource.fetchRelatedTracks('track-1')).single.id,
          'related-1',
        );

        when(
          () => dio.get<Map<String, dynamic>>(
            '/tracks/fail/related',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/tracks/fail/related'));
        expect(await datasource.fetchRelatedTracks('fail'), isEmpty);
      },
    );

    test(
      'fetchMixTracks supports map, list, malformed, and network responses',
      () async {
        when(() => dio.get<Map<String, dynamic>>('/home/mixes/map')).thenAnswer(
          (_) async => _response('/home/mixes/map', {
            'data': {
              'tracks': [
                _trackJson('mix-1'),
                {'id': ''},
                'bad',
              ],
            },
          }),
        );
        expect((await datasource.fetchMixTracks('map')).single.id, 'mix-1');

        when(
          () => dio.get<Map<String, dynamic>>('/home/mixes/list'),
        ).thenAnswer(
          (_) async => _response('/home/mixes/list', {
            'data': [_trackJson('mix-2')],
          }),
        );
        expect((await datasource.fetchMixTracks('list')).single.id, 'mix-2');

        when(
          () => dio.get<Map<String, dynamic>>('/home/mixes/bad'),
        ).thenAnswer((_) async => _response('/home/mixes/bad', {'data': 42}));
        expect(await datasource.fetchMixTracks('bad'), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>('/home/mixes/fail'),
        ).thenThrow(_dioError('/home/mixes/fail'));
        expect(await datasource.fetchMixTracks('fail'), isEmpty);
      },
    );

    test(
      'daily and weekly mix endpoints support map, list, malformed, and failure responses',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/daily'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/daily', {
            'data': {
              'tracks': [_trackJson('daily-map')],
            },
          }),
        );
        expect((await datasource.fetchDailyMixTracks()).single.id, 'daily-map');

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/daily'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/daily', {
            'data': [_trackJson('daily-list')],
          }),
        );
        expect(
          (await datasource.fetchDailyMixTracks()).single.id,
          'daily-list',
        );

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/daily'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/daily', {'data': null}),
        );
        expect(await datasource.fetchDailyMixTracks(), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/daily'),
        ).thenThrow(_dioError('/home/made-for-you/daily'));
        expect(await datasource.fetchDailyMixTracks(), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/weekly'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/weekly', {
            'data': {
              'tracks': [_trackJson('weekly-map')],
            },
          }),
        );
        expect(
          (await datasource.fetchWeeklyMixTracks()).single.id,
          'weekly-map',
        );

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/weekly'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/weekly', {
            'data': [_trackJson('weekly-list')],
          }),
        );
        expect(
          (await datasource.fetchWeeklyMixTracks()).single.id,
          'weekly-list',
        );

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/weekly'),
        ).thenAnswer(
          (_) async => _response('/home/made-for-you/weekly', {'data': 'bad'}),
        );
        expect(await datasource.fetchWeeklyMixTracks(), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>('/home/made-for-you/weekly'),
        ).thenThrow(_dioError('/home/made-for-you/weekly'));
        expect(await datasource.fetchWeeklyMixTracks(), isEmpty);
      },
    );

    test(
      'fetchRecommendedTracks reads genre IDs, skips invalid tracks, dedupes, and excludes',
      () async {
        when(() => dio.get<Map<String, dynamic>>('/home')).thenAnswer(
          (_) async => _response('/home', {
            'data': {
              'trending_by_genre': {
                'genres': [
                  {'genre_id': 'genre-1'},
                  {'genre_id': 'genre-2'},
                  {'genre_id': ''},
                ],
              },
            },
          }),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/genres/genre-1/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/genres/genre-1/tracks', {
            'data': [
              _trackJson('rec-1'),
              _trackJson('rec-2'),
              _trackJson('rec-1'),
              _trackJson('c0000-seed'),
              {'title': 'missing id'},
            ],
          }),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/genres/genre-2/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/genres/genre-2/tracks', {
            'data': {
              'tracks': [_trackJson('rec-3'), 'malformed'],
            },
          }),
        );

        final result = await datasource.fetchRecommendedTracks(limit: 10);
        expect(result.map((t) => t.id).toSet(), {'rec-1', 'rec-2', 'rec-3'});

        when(() => dio.get<Map<String, dynamic>>('/home')).thenAnswer(
          (_) async => _response('/home', {
            'data': {
              'trending_by_genre': {
                'genres': [
                  {'genre_id': 'genre-1'},
                ],
              },
            },
          }),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/genres/genre-1/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _response('/genres/genre-1/tracks', {
            'data': [_trackJson('rec-1'), _trackJson('rec-2')],
          }),
        );
        final excluding = await datasource.fetchRecommendedTracksExcluding(
          excludeIds: ['rec-1'],
          limit: 5,
        );
        expect(excluding.map((t) => t.id), ['rec-2']);
      },
    );

    test(
      'fetchRecommendedTracks returns empty for missing home genres, genre failures, and malformed payloads',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>('/home'),
        ).thenAnswer((_) async => _response('/home', {'data': {}}));
        expect(await datasource.fetchRecommendedTracks(), isEmpty);

        when(() => dio.get<Map<String, dynamic>>('/home')).thenAnswer(
          (_) async => _response('/home', {
            'data': {
              'trending_by_genre': {
                'genres': [
                  {'genre_id': 'genre-fail'},
                ],
              },
            },
          }),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/genres/genre-fail/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/genres/genre-fail/tracks'));
        expect(await datasource.fetchRecommendedTracks(), isEmpty);

        when(
          () => dio.get<Map<String, dynamic>>('/home'),
        ).thenThrow(_dioError('/home'));
        expect(await datasource.fetchRecommendedTracks(), isEmpty);
      },
    );
  });

  group('engagement endpoints', () {
    test(
      'like, unlike, repost, and remove-repost call the correct endpoints',
      () async {
        when(() => dio.post<dynamic>('/playlists/playlist-1/like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/playlists/playlist-1/like'),
          ),
        );
        when(
          () => dio.delete<dynamic>('/playlists/playlist-1/like'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/playlists/playlist-1/like'),
          ),
        );
        when(
          () => dio.post<dynamic>('/playlists/playlist-1/repost'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/playlists/playlist-1/repost',
            ),
          ),
        );
        when(
          () => dio.delete<dynamic>('/playlists/playlist-1/repost'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/playlists/playlist-1/repost',
            ),
          ),
        );

        await datasource.likePlaylist('playlist-1');
        await datasource.unlikePlaylist('playlist-1');
        await datasource.repostPlaylist('playlist-1');
        await datasource.removeRepost('playlist-1');

        verify(() => dio.post<dynamic>('/playlists/playlist-1/like')).called(1);
        verify(
          () => dio.delete<dynamic>('/playlists/playlist-1/like'),
        ).called(1);
        verify(
          () => dio.post<dynamic>('/playlists/playlist-1/repost'),
        ).called(1);
        verify(
          () => dio.delete<dynamic>('/playlists/playlist-1/repost'),
        ).called(1);
      },
    );

    test(
      'mix, station, and track-radio engagement endpoints parse responses and rethrow failures',
      () async {
        when(() => dio.post<dynamic>('/home/mixes/mix-1/like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/home/mixes/mix-1/like'),
          ),
        );
        when(() => dio.delete<dynamic>('/home/mixes/mix-1/like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/home/mixes/mix-1/like'),
          ),
        );
        when(() => dio.post<dynamic>('/stations/artist-1/like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/stations/artist-1/like'),
          ),
        );
        when(() => dio.delete<dynamic>('/stations/artist-1/like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/stations/artist-1/like'),
          ),
        );
        when(
          () => dio.post<Map<String, dynamic>>('/tracks/track-1/like-radio'),
        ).thenAnswer(
          (_) async => _response('/tracks/track-1/like-radio', {
            'data': {'playlist_id': 'radio-playlist-1'},
          }),
        );
        when(
          () => dio.delete<dynamic>('/tracks/track-1/like-radio'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/tracks/track-1/like-radio'),
          ),
        );

        await datasource.likeMix('mix-1');
        await datasource.unlikeMix('mix-1');
        await datasource.likeStation('artist-1');
        await datasource.unlikeStation('artist-1');
        expect(await datasource.likeTrackRadio('track-1'), 'radio-playlist-1');
        await datasource.unlikeTrackRadio('track-1');

        when(
          () => dio.post<dynamic>('/home/mixes/fail/like'),
        ).thenThrow(_dioError('/home/mixes/fail/like'));
        expect(() => datasource.likeMix('fail'), throwsA(isA<DioException>()));
      },
    );

    test(
      'critical write endpoints rethrow server, network, and authorization failures',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/playlists',
            data: any(named: 'data'),
          ),
        ).thenThrow(_dioError('/playlists', 422));
        expect(
          () => datasource.createPlaylist(name: '', isPublic: true),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.delete<void>('/playlists/playlist-1'),
        ).thenThrow(_dioError('/playlists/playlist-1', 403));
        expect(
          () => datasource.deletePlaylist('playlist-1'),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.post<dynamic>(
            '/playlists/playlist-1/tracks',
            data: any(named: 'data'),
          ),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks', 500));
        expect(
          () => datasource.addTrackToPlaylist(
            playlistId: 'playlist-1',
            trackId: 'track-1',
          ),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.delete<dynamic>('/playlists/playlist-1/tracks/track-1'),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks/track-1', 404));
        expect(
          () => datasource.removeTrackFromPlaylist(
            playlistId: 'playlist-1',
            trackId: 'track-1',
          ),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.patch<dynamic>(
            '/playlists/playlist-1/tracks/reorder',
            data: any(named: 'data'),
          ),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks/reorder', 409));
        expect(
          () => datasource.reorderPlaylistTracks(
            playlistId: 'playlist-1',
            orderedTrackIds: ['track-1'],
          ),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.post<dynamic>('/playlists/fail/like'),
        ).thenThrow(_dioError('/playlists/fail/like', 401));
        when(
          () => dio.delete<dynamic>('/playlists/fail/like'),
        ).thenThrow(_dioError('/playlists/fail/like', 401));
        when(
          () => dio.delete<dynamic>('/home/mixes/fail/like'),
        ).thenThrow(_dioError('/home/mixes/fail/like', 500));
        when(
          () => dio.post<dynamic>('/stations/fail/like'),
        ).thenThrow(_dioError('/stations/fail/like', 500));
        when(
          () => dio.delete<dynamic>('/stations/fail/like'),
        ).thenThrow(_dioError('/stations/fail/like', 500));
        when(
          () => dio.post<Map<String, dynamic>>('/tracks/fail/like-radio'),
        ).thenThrow(_dioError('/tracks/fail/like-radio', 500));
        when(
          () => dio.delete<dynamic>('/tracks/fail/like-radio'),
        ).thenThrow(_dioError('/tracks/fail/like-radio', 500));
        when(
          () => dio.post<dynamic>('/playlists/fail/repost'),
        ).thenThrow(_dioError('/playlists/fail/repost', 500));
        when(
          () => dio.delete<dynamic>('/playlists/fail/repost'),
        ).thenThrow(_dioError('/playlists/fail/repost', 500));

        expect(
          () => datasource.likePlaylist('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.unlikePlaylist('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.unlikeMix('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.likeStation('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.unlikeStation('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.likeTrackRadio('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.unlikeTrackRadio('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.repostPlaylist('fail'),
          throwsA(isA<DioException>()),
        );
        expect(
          () => datasource.removeRepost('fail'),
          throwsA(isA<DioException>()),
        );
      },
    );
  });

  group('core failure paths', () {
    test(
      'fetchUserPlaylists and paginated tracks rethrow protected API failures',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/users/private/playlists',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/users/private/playlists', 403));
        expect(
          () => datasource.fetchUserPlaylists(userId: 'private'),
          throwsA(isA<DioException>()),
        );

        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-1/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks', 500));
        expect(
          () => datasource.fetchPlaylistTracks('playlist-1'),
          throwsA(isA<DioException>()),
        );
      },
    );
  });
}
