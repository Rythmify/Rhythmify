import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:rythmify/features/feed/data/models/feed_dto.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

// ============ Test Fixtures ============

final tUserJson = {
  'id': 'user-1',
  'username': 'testuser',
  'displayName': 'Test User',
  'followers': 1000,
  'isVerified': true,
  'is_following': true,
  'profile_picture': 'https://example.com/avatar.jpg',
};

final tTrackJson = {
  'id': 'track-1',
  'title': 'Test Track',
  'duration': 180,
  'play_count': 5000,
  'like_count': 500,
  'comment_count': 10,
  'cover_image': 'https://example.com/cover.jpg',
  'audio_url': 'https://example.com/audio.mp3',
  'artist': {
    'id': 'artist-1',
    'username': 'artist',
    'is_following': false,
    'profile_picture': 'https://example.com/artist.jpg',
  },
};

final tArtistJson = {
  'id': 'artist-1',
  'username': 'artist',
  'is_following': false,
  'profile_picture': 'https://example.com/artist.jpg',
};

// Feed item with a direct track
final tFeedItemWithTrack = {
  'id': 'feed-1',
  'type': 'post',
  'content_type': 'track',
  'created_at': '2024-01-01T00:00:00Z',
  'user': tUserJson,
  'track': tTrackJson,
};

// Feed item with a playlist containing tracks
final tFeedItemWithPlaylist = {
  'id': 'feed-2',
  'type': 'post',
  'content_type': 'playlist',
  'created_at': '2024-01-01T00:00:00Z',
  'user': tUserJson,
  'track': null,
  'playlist': {
    'id': 'playlist-1',
    'title': 'Test Playlist',
    'cover_image': 'https://example.com/playlist.jpg',
    'tracks': [tTrackJson],
  },
};

// Feed item with no track and no playlist tracks — should be filtered out
final tFeedItemNoTrack = {
  'id': 'feed-3',
  'type': 'post',
  'content_type': 'track',
  'created_at': '2024-01-01T00:00:00Z',
  'user': tUserJson,
  'track': null,
  'playlist': null,
};

// Feed item where track has no artist — falls back to user
final tFeedItemTrackNoArtist = {
  'id': 'feed-4',
  'type': 'post',
  'content_type': 'track',
  'created_at': '2024-01-01T00:00:00Z',
  'user': tUserJson,
  'track': {
    'id': 'track-2',
    'title': 'No Artist Track',
    'duration': 200,
    'play_count': 100,
    'like_count': 10,
    'comment_count': 2,
    'cover_image': 'https://example.com/cover2.jpg',
    'audio_url': 'https://example.com/audio2.mp3',
    // no 'artist' or 'user' key — falls back to userJson
  },
};

// Discover item with full reason label
final tDiscoverItemWithLabel = {
  'id': 'discover-1',
  'reason': {'label': 'Trending in Electronic'},
  'track': {...tTrackJson, 'artist': tArtistJson},
};

// Discover item with null reason — uses default label
final tDiscoverItemNullReason = {
  'id': 'discover-2',
  'reason': null,
  'track': {...tTrackJson, 'artist': tArtistJson},
};

// Discover item with no track — should be filtered out
final tDiscoverItemNoTrack = {
  'id': 'discover-3',
  'reason': {'label': 'Some reason'},
  'track': null,
};

// Discover item with artist missing optional fields
final tDiscoverItemMinimalArtist = {
  'id': 'discover-4',
  'reason': {'label': 'Because you liked it'},
  'track': {
    ...tTrackJson,
    'artist':
        <String, dynamic>{}, // empty artist — all fields fall back to defaults
  },
};

void main() {
  late FeedRemoteDatasourceImpl datasource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    datasource = FeedRemoteDatasourceImpl(client: mockApiClient);
  });

  // Helper to mock a successful /feed response
  void mockFollowingFeed(List<Map<String, dynamic>> data) {
    when(() => mockApiClient.getToken()).thenAnswer((_) async => 'test-token');
    when(() => mockDio.get('/feed', options: any(named: 'options'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/feed'),
        data: {'data': data},
        statusCode: 200,
      ),
    );
  }

  // Helper to mock a successful /feed/discovery response
  void mockDiscoverFeed(List<Map<String, dynamic>> data) {
    when(() => mockApiClient.getToken()).thenAnswer((_) async => 'test-token');
    when(
      () => mockDio.get('/feed/discovery', options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/feed/discovery'),
        data: {'data': data},
        statusCode: 200,
      ),
    );
  }

  group('FeedRemoteDatasourceImpl', () {
    group('getFollowingFeed', () {
      test('returns list of FeedItemModel on success', () async {
        mockFollowingFeed([tFeedItemWithTrack]);

        final result = await datasource.getFollowingFeed();

        expect(result, isA<List<FeedItemModel>>());
        expect(result.length, 1);
        expect(result.first.id, 'feed-1');
        expect(result.first.type, 'post');
      });

      test('filters out items with no track and no playlist', () async {
        mockFollowingFeed([tFeedItemWithTrack, tFeedItemNoTrack]);

        final result = await datasource.getFollowingFeed();

        // tFeedItemNoTrack should be filtered by whereType (returns null)
        expect(result.length, 1);
        expect(result.first.id, 'feed-1');
      });

      test('resolves track from playlist tracks when track is null', () async {
        mockFollowingFeed([tFeedItemWithPlaylist]);

        final result = await datasource.getFollowingFeed();

        expect(result.length, 1);
        expect(result.first.playlist, isNotNull);
        expect(result.first.id, 'feed-2');
      });

      test('falls back to userJson when track has no artist or user', () async {
        mockFollowingFeed([tFeedItemTrackNoArtist]);

        final result = await datasource.getFollowingFeed();

        expect(result.length, 1);
        // trackOwner should fall back to the post's user
        expect(result.first.trackOwner.id, 'user-1');
      });

      test('returns empty list when data array is empty', () async {
        mockFollowingFeed([]);

        final result = await datasource.getFollowingFeed();

        expect(result, isEmpty);
      });

      test('throws when dio throws a non-caught exception', () async {
        when(
          () => mockApiClient.getToken(),
        ).thenAnswer((_) async => 'test-token');
        when(
          () => mockDio.get('/feed', options: any(named: 'options')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/feed'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => datasource.getFollowingFeed(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getDiscoverFeed', () {
      test('returns list of FeedItemModel on success', () async {
        mockDiscoverFeed([tDiscoverItemWithLabel]);

        final result = await datasource.getDiscoverFeed();

        expect(result, isA<List<FeedItemModel>>());
        expect(result.length, 1);
        expect(result.first.id, 'discover-1');
        expect(result.first.type, 'discover');
        expect(result.first.discoverLabel, 'Trending in Electronic');
      });

      test('uses default label when reason is null', () async {
        mockDiscoverFeed([tDiscoverItemNullReason]);

        final result = await datasource.getDiscoverFeed();

        expect(result.length, 1);
        expect(result.first.discoverLabel, 'Discovered for you');
      });

      test('filters out items with no track', () async {
        mockDiscoverFeed([tDiscoverItemWithLabel, tDiscoverItemNoTrack]);

        final result = await datasource.getDiscoverFeed();

        expect(result.length, 1);
        expect(result.first.id, 'discover-1');
      });

      test('handles empty artist fields gracefully', () async {
        mockDiscoverFeed([tDiscoverItemMinimalArtist]);

        final result = await datasource.getDiscoverFeed();

        expect(result.length, 1);
        expect(result.first.trackOwner.id, '');
        expect(result.first.trackOwner.username, '');
      });

      test('returns empty list when data array is empty', () async {
        mockDiscoverFeed([]);

        final result = await datasource.getDiscoverFeed();

        expect(result, isEmpty);
      });

      test(
        'returns empty list when dio throws — caught by try/catch',
        () async {
          when(
            () => mockApiClient.getToken(),
          ).thenAnswer((_) async => 'test-token');
          when(
            () =>
                mockDio.get('/feed/discovery', options: any(named: 'options')),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/feed/discovery'),
              type: DioExceptionType.connectionTimeout,
            ),
          );

          // getDiscoverFeed catches all exceptions and returns []
          final result = await datasource.getDiscoverFeed();
          expect(result, isEmpty);
        },
      );
    });
  });
}
