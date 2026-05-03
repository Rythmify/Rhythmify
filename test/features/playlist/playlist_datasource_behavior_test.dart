import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';

class MockDio extends Mock implements Dio {}

Map<String, dynamic> _playlistJson({
  String id = 'playlist-1',
  String name = 'Night Drive',
  bool isPublic = true,
  String subtype = 'playlist',
}) {
  return {
    'playlist_id': id,
    'name': name,
    'owner_user_id': 'user-1',
    'is_public': isPublic,
    'subtype': subtype,
    'type': 'regular',
    'track_count': 2,
    'created_at': '2024-01-02T03:04:05Z',
  };
}

Map<String, dynamic> _trackJson(String id, int position) {
  return {
    'track_id': id,
    'title': 'Track $id',
    'artist_name': 'Artist $id',
    'duration': 90,
    'position': position,
    'is_public': true,
  };
}

Response<Map<String, dynamic>> _jsonResponse(
  String path,
  Map<String, dynamic> data,
) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

void main() {
  late MockDio dio;
  late PlaylistRemoteDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = PlaylistRemoteDatasource(dio);
  });

  group('PlaylistRemoteDatasource core playlist calls', () {
    test(
      'fetchMyPlaylists sends mine/filter/limit and marks created lists owned',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _jsonResponse('/playlists', {
            'data': {
              'items': [_playlistJson(id: 'owned-1')],
            },
          }),
        );

        final result = await datasource.fetchMyPlaylists();

        expect(result, hasLength(1));
        expect(result.first.id, 'owned-1');
        expect(result.first.isOwned, isTrue);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists',
            queryParameters: {'mine': true, 'filter': 'created', 'limit': 50},
          ),
        ).called(1);
      },
    );

    test(
      'fetchMyPlaylists supports liked/album filters without ownership',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _jsonResponse('/playlists', {
            'data': {
              'items': [_playlistJson(id: 'album-1', subtype: 'album')],
            },
          }),
        );

        final result = await datasource.fetchMyPlaylists(
          filter: 'liked',
          subtype: 'album',
        );

        expect(result.single.id, 'album-1');
        expect(result.single.type, PlaylistType.album);
        expect(result.single.isOwned, isFalse);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists',
            queryParameters: {
              'mine': true,
              'filter': 'liked',
              'limit': 50,
              'subtype': 'album',
            },
          ),
        ).called(1);
      },
    );

    test(
      'createPlaylist posts public/private metadata and parses response',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            '/playlists',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => _jsonResponse('/playlists', {
            'data': _playlistJson(
              id: 'new-1',
              name: 'Private',
              isPublic: false,
            ),
          }),
        );

        final result = await datasource.createPlaylist(
          name: 'Private',
          isPublic: false,
        );

        expect(result.id, 'new-1');
        expect(result.isPublic, isFalse);
        expect(result.isOwned, isTrue);
        verify(
          () => dio.post<Map<String, dynamic>>(
            '/playlists',
            data: {
              'name': 'Private',
              'is_public': false,
              'subtype': 'playlist',
            },
          ),
        ).called(1);
      },
    );

    test('deletePlaylist calls the correct endpoint', () async {
      when(() => dio.delete<void>('/playlists/delete-me')).thenAnswer(
        (_) async => Response<void>(
          requestOptions: RequestOptions(path: '/playlists/delete-me'),
          statusCode: 204,
        ),
      );

      await datasource.deletePlaylist('delete-me');

      verify(() => dio.delete<void>('/playlists/delete-me')).called(1);
    });

    test(
      'rethrows DioException for unauthorized or invalid playlist access',
      () async {
        final error = DioException(
          requestOptions: RequestOptions(path: '/playlists/bad-id'),
          response: Response(
            requestOptions: RequestOptions(path: '/playlists/bad-id'),
            statusCode: 403,
            data: {
              'error': {'code': 'PLAYLIST_ACCESS_DENIED'},
            },
          ),
        );
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/bad-id',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(error);

        expect(
          () => datasource.fetchPlaylistDetail('bad-id'),
          throwsA(isA<DioException>()),
        );
      },
    );
  });

  group('PlaylistRemoteDatasource track management', () {
    test(
      'fetchPlaylistTracks walks pagination and preserves all pages',
      () async {
        when(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-1/tracks',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((invocation) async {
          final query =
              invocation.namedArguments[#queryParameters]
                  as Map<String, dynamic>;
          final page = query['page'] as int;
          return _jsonResponse('/playlists/playlist-1/tracks', {
            'data': {
              'tracks': page == 1
                  ? [_trackJson('t2', 2), _trackJson('t1', 1)]
                  : [_trackJson('t3', 3)],
              'pagination': {'has_next': page == 1},
            },
          });
        });

        final result = await datasource.fetchPlaylistTracks('playlist-1');

        expect(result.map((t) => t.id), ['t1', 't2', 't3']);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-1/tracks',
            queryParameters: {'page': 1, 'limit': 20},
          ),
        ).called(1);
        verify(
          () => dio.get<Map<String, dynamic>>(
            '/playlists/playlist-1/tracks',
            queryParameters: {'page': 2, 'limit': 20},
          ),
        ).called(1);
      },
    );

    test(
      'addTrackToPlaylist sends position and treats duplicates as success',
      () async {
        when(
          () => dio.post<dynamic>(
            '/playlists/playlist-1/tracks',
            data: any(named: 'data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/playlists/playlist-1/tracks',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: '/playlists/playlist-1/tracks',
              ),
              statusCode: 409,
            ),
          ),
        );

        await datasource.addTrackToPlaylist(
          playlistId: 'playlist-1',
          trackId: 'track-1',
          position: 2,
        );

        verify(
          () => dio.post<dynamic>(
            '/playlists/playlist-1/tracks',
            data: {'track_id': 'track-1', 'position': 2},
          ),
        ).called(1);
      },
    );

    test(
      'removeTrackFromPlaylist and reorder call correct endpoints',
      () async {
        when(
          () => dio.delete<dynamic>('/playlists/playlist-1/tracks/track-1'),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/playlists/playlist-1/tracks/track-1',
            ),
            statusCode: 204,
          ),
        );
        when(
          () => dio.patch<dynamic>(
            '/playlists/playlist-1/tracks/reorder',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/playlists/playlist-1/tracks/reorder',
            ),
            statusCode: 200,
          ),
        );

        await datasource.removeTrackFromPlaylist(
          playlistId: 'playlist-1',
          trackId: 'track-1',
        );
        await datasource.reorderPlaylistTracks(
          playlistId: 'playlist-1',
          orderedTrackIds: ['track-2', 'track-1'],
        );

        verify(
          () => dio.delete<dynamic>('/playlists/playlist-1/tracks/track-1'),
        ).called(1);
        verify(
          () => dio.patch<dynamic>(
            '/playlists/playlist-1/tracks/reorder',
            data: {
              'items': [
                {'track_id': 'track-2', 'position': 1},
                {'track_id': 'track-1', 'position': 2},
              ],
            },
          ),
        ).called(1);
      },
    );
  });
}
