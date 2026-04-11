import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/comments/data/datasources/comment_remote_datasource.dart';
import 'package:rythmify/features/comments/data/models/comment_dto.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late CommentRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = CommentRemoteDataSourceImpl(mockApiClient);
  });

  final tCommentJson = {
    'comment_id': 'comment-123',
    'track_id': 'track-456',
    'user_id': 'user-789',
    'content': 'Great track!',
    'track_timestamp': 45000,
    'created_at': '2023-10-15T10:00:00.000Z',
    'like_count': 10,
    'is_liked_by_me': false,
    'reply_count': 2,
    'parent_comment_id': null,
    'author': {
      'display_name': 'John Doe',
      'avatar_url': 'https://example.com/pfp.png',
    },
  };

  group('getTrackComments', () {
    test('should perform a GET request and return a list of CommentDto', () async {
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': {
              'items': [tCommentJson],
            },
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getTrackComments(
        trackId: 'track-456',
        page: 2,
        limit: 20,
        sortValue: 'newest',
      );

      expect(result, isA<List<CommentDto>>());
      expect(result.length, 1);
      expect(result.first.id, 'comment-123');

      verify(
        () => mockDio.get(
          '/tracks/track-456/comments',
          queryParameters: {
            'limit': 20,
            'offset': 20,
            'sort': 'newest',
          },
        ),
      ).called(1);
    });
  });

  group('getCommentReplies', () {
    test('should perform a GET request and return a list of replies', () async {
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': {
              'items': [tCommentJson],
            },
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getCommentReplies(
        commentId: 'comment-123',
        page: 1,
        limit: 10,
        sortValue: 'oldest',
      );

      expect(result, isA<List<CommentDto>>());
      expect(result.length, 1);

      verify(
        () => mockDio.get(
          '/comments/comment-123/replies',
          queryParameters: {
            'limit': 10,
            'offset': 0,
            'sort': 'oldest',
          },
        ),
      ).called(1);
    });
  });

  group('getAllCommentsForTrack', () {
    test('should perform a GET request for a large batch', () async {
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': {
              'items': [tCommentJson],
            },
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getAllCommentsForTrack('track-456');

      expect(result.length, 1);
      verify(
        () => mockDio.get(
          '/tracks/track-456/comments',
          queryParameters: {
            'limit': 1000,
            'offset': 0,
          },
        ),
      ).called(1);
    });
  });

  group('postComment', () {
    test('should perform a POST request and return the created CommentDto', () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': tCommentJson,
          },
          statusCode: 201,
        ),
      );

      final result = await dataSource.postComment(
        trackId: 'track-456',
        content: 'Great track!',
        trackTimestamp: 45000,
        parentId: 'parent-123',
      );

      expect(result.id, 'comment-123');
      verify(
        () => mockDio.post(
          '/tracks/track-456/comments',
          data: {
            'content': 'Great track!',
            'track_timestamp': 45000,
            'parent_comment_id': 'parent-123',
          },
        ),
      ).called(1);
    });
  });

  group('likeComment & unlikeComment', () {
    test('likeComment performs POST request', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await dataSource.likeComment('comment-123');

      verify(() => mockDio.post('/comments/comment-123/like')).called(1);
    });

    test('unlikeComment performs DELETE request', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await dataSource.unlikeComment('comment-123');

      verify(() => mockDio.delete('/comments/comment-123/like')).called(1);
    });
  });

  group('deleteComment', () {
    test('performs DELETE request', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await dataSource.deleteComment('comment-123');

      verify(() => mockDio.delete('/comments/comment-123')).called(1);
    });
  });

  group('blockUser & unblockUser', () {
    test('blockUser performs POST request', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await dataSource.blockUser('user-789');

      verify(() => mockDio.post('/users/user-789/block')).called(1);
    });

    test('unblockUser performs DELETE request', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await dataSource.unblockUser('user-789');

      verify(() => mockDio.delete('/users/user-789/block')).called(1);
    });
  });
}
