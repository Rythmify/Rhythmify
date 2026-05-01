import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/feed/data/datasources/feed_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late FeedRemoteDatasourceImpl datasource;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    datasource = FeedRemoteDatasourceImpl(client: mockApiClient);
  });

  test(
    'getFollowingFeed extracts track from playlist when track is null',
    () async {
      const token = 't';
      final playlistTrack = {
        'id': 'pl-track-1',
        'title': 'Playlist Track',
        'user': {'id': 'owner-1', 'username': 'owner'},
        'audio_url': 'https://example.com/p.mp3',
      };

      final item = {
        'id': 'feed-pl-1',
        'type': 'playlist_post',
        'content_type': 'playlist',
        'created_at': '2024-01-01T00:00:00Z',
        'user': {'id': 'poster-1', 'username': 'poster'},
        'track': null,
        'playlist': {
          'id': 'pl-1',
          'title': 'Pl',
          'tracks': [playlistTrack],
        },
      };

      when(() => mockApiClient.getToken()).thenAnswer((_) async => token);
      when(
        () => mockDio.get('/feed', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': [item],
          },
          statusCode: 200,
        ),
      );

      final res = await datasource.getFollowingFeed();
      expect(res.length, 1);
      expect(res.first.track.id, 'pl-track-1');
      expect(res.first.playlist!.id, 'pl-1');
    },
  );

  test('getDiscoverFeed maps owner when artist missing username', () async {
    const token = 't';
    final discoverItem = {
      'id': 'd-1',
      'reason': {'label': 'L'},
      'track': {
        'id': 't-1',
        'title': 'T',
        'artist': {'id': 'a1'},
      },
    };

    when(() => mockApiClient.getToken()).thenAnswer((_) async => token);
    when(
      () => mockDio.get('/feed/discovery', options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'data': [discoverItem],
        },
        statusCode: 200,
      ),
    );

    final res = await datasource.getDiscoverFeed();
    expect(res.length, 1);
    expect(res.first.user.id, 'a1');
    expect(res.first.user.username, '');
  });
}
