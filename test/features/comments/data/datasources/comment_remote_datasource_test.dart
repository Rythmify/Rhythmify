import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/comments/data/datasources/comment_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late CommentRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

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
    'is_user_blocked': true,
    'author': {
      'display_name': 'John Doe',
      'avatar_url': 'https://example.com/pfp.png',
    },
  };

  Response<dynamic> response(dynamic data, {int statusCode = 200}) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = CommentRemoteDataSourceImpl(mockApiClient);
  });

  group('CommentRemoteDataSourceImpl', () {
    test(
      'getTrackComments passes pagination and parses wrapped items',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => response({
            'data': {
              'items': [tCommentJson],
            },
          }),
        );

        final result = await dataSource.getTrackComments(
          trackId: 'track-456',
          page: 2,
          limit: 20,
          sortValue: 'oldest',
        );

        expect(result.single.id, 'comment-123');
        expect(result.single.isAuthorBlocked, true);
        verify(
          () => mockDio.get(
            '/tracks/track-456/comments',
            queryParameters: {'limit': 20, 'offset': 20, 'sort': 'oldest'},
          ),
        ).called(1);
      },
    );

    test(
      'getTrackComments parses list response and empty malformed data',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => response({
            'data': [tCommentJson],
          }),
        );

        final listResult = await dataSource.getTrackComments(
          trackId: 'track-456',
          page: 1,
          limit: 10,
          sortValue: 'newest',
        );
        expect(listResult, hasLength(1));

        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => response({
            'data': {'items': 'not-list'},
          }),
        );

        final emptyResult = await dataSource.getTrackComments(
          trackId: 'track-456',
          page: 1,
          limit: 10,
          sortValue: 'newest',
        );
        expect(emptyResult, isEmpty);
      },
    );

    test('getTrackComments rethrows DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      expect(
        () => dataSource.getTrackComments(
          trackId: 'track-456',
          page: 1,
          limit: 20,
          sortValue: 'newest',
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('getCommentReplies and getReplies parse paged replies', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => response({
          'data': [tCommentJson],
        }),
      );

      final sortedReplies = await dataSource.getCommentReplies(
        commentId: 'comment-123',
        page: 3,
        limit: 5,
        sortValue: 'timestamp',
      );
      final replies = await dataSource.getReplies(
        commentId: 'comment-123',
        limit: 7,
        offset: 14,
      );

      expect(sortedReplies.single.id, 'comment-123');
      expect(replies.single.id, 'comment-123');
      verify(
        () => mockDio.get(
          '/comments/comment-123/replies',
          queryParameters: {'limit': 5, 'offset': 10, 'sort': 'timestamp'},
        ),
      ).called(1);
      verify(
        () => mockDio.get(
          '/comments/comment-123/replies',
          queryParameters: {'limit': 7, 'offset': 14},
        ),
      ).called(1);
    });

    test(
      'getAllCommentsForTrack falls back from timestamp sort type error',
      () async {
        final failingResponse = Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
          data: {
            'error': {'code': '42P18'},
          },
        );
        var calls = 0;
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async {
          calls++;
          if (calls == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: ''),
              response: failingResponse,
            );
          }
          return response({
            'data': [tCommentJson],
          });
        });

        final result = await dataSource.getAllCommentsForTrack('track-456');

        expect(result.single.id, 'comment-123');
        verify(
          () => mockDio.get(
            '/tracks/track-456/comments',
            queryParameters: {'limit': 100, 'offset': 0, 'sort': 'timestamp'},
          ),
        ).called(1);
        verify(
          () => mockDio.get(
            '/tracks/track-456/comments',
            queryParameters: {'limit': 100, 'offset': 0, 'sort': 'newest'},
          ),
        ).called(1);
      },
    );

    test('getAllCommentsForTrack rethrows non fallback DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {
              'error': {'code': 'OTHER'},
            },
          ),
        ),
      );

      expect(
        () => dataSource.getAllCommentsForTrack('track-456'),
        throwsA(isA<DioException>()),
      );
    });

    test('postComment and postReply send current payloads', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => response({'data': tCommentJson}, statusCode: 201),
      );

      final comment = await dataSource.postComment(
        trackId: 'track-456',
        content: 'hi',
        trackTimestamp: 45,
        parentId: 'parent-1',
      );
      final reply = await dataSource.postReply(
        commentId: 'comment-123',
        content: 'reply',
      );

      expect(comment.id, 'comment-123');
      expect(reply.id, 'comment-123');
      verify(
        () => mockDio.post(
          '/tracks/track-456/comments',
          data: {
            'content': 'hi',
            'track_timestamp': 45,
            'parent_comment_id': 'parent-1',
          },
        ),
      ).called(1);
      verify(
        () => mockDio.post(
          '/comments/comment-123/replies',
          data: {'content': 'reply'},
        ),
      ).called(1);
    });

    test(
      'like, unlike, delete, block, and unblock hit expected endpoints',
      () async {
        when(
          () => mockDio.post(any()),
        ).thenAnswer((_) async => response(null, statusCode: 204));
        when(
          () => mockDio.delete(any()),
        ).thenAnswer((_) async => response(null, statusCode: 204));

        await dataSource.likeComment('comment-123');
        await dataSource.unlikeComment('comment-123');
        await dataSource.deleteComment('comment-123');
        await dataSource.blockUser('user-123');
        await dataSource.unblockUser('user-123');

        verify(() => mockDio.post('/comments/comment-123/like')).called(1);
        verify(() => mockDio.delete('/comments/comment-123/like')).called(1);
        verify(() => mockDio.delete('/comments/comment-123')).called(1);
        verify(() => mockDio.post('/users/user-123/block')).called(1);
        verify(() => mockDio.delete('/users/user-123/block')).called(1);
      },
    );
  });
}
