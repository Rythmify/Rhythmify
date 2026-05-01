import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/notifications/data/datasources/notification_datasources_impl.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late NotificationDatasourcesImpl datasource;
  late MockDio mockDio;

  final tFollowJson = {
    'id': 'n1',
    'type': 'follow',
    'actor': {'id': 'u1', 'display_name': 'Alice'},
    'is_read': false,
    'created_at': '2024-01-15T10:30:00.000Z',
  };

  final tNewPostJson = {
    'id': 'n2',
    'type': 'new_post_by_followed',
    'actor': {'id': 'u2', 'display_name': 'Bob'},
    'is_read': false,
    'created_at': '2024-01-15T10:30:00.000Z',
  };

  setUp(() {
    mockDio = MockDio();
    datasource = NotificationDatasourcesImpl(mockDio);
  });

  group('getNotifications', () {
    test('performs GET /notifications and returns parsed results', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/notifications'),
          statusCode: 200,
          data: {
            'data': {
              'items': [tFollowJson],
              'unread_count': 3,
              'pagination': {'has_next': true},
            },
          },
        ),
      );

      final result = await datasource.getNotifications(page: 1, limit: 20);

      expect(result.unreadCount, 3);
      expect(result.hasNext, true);
      expect(result.items, isNotEmpty);
      expect(result.items.first.type, NotificationType.follow);
      verify(
        () => mockDio.get(
          '/notifications',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('includes unread_only and type params when provided', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/notifications'),
          statusCode: 200,
          data: {
            'data': {
              'items': [tFollowJson],
              'unread_count': 1,
              'pagination': {'has_next': false},
            },
          },
        ),
      );

      final result = await datasource.getNotifications(
        page: 1,
        limit: 10,
        unreadOnly: true,
        type: 'follow',
      );

      expect(result.items, isNotEmpty);
    });

    test('filters out newPostByFollowed notifications', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {
              'items': [tNewPostJson],
              'unread_count': 1,
              'pagination': {'has_next': false},
            },
          },
        ),
      );

      final result = await datasource.getNotifications();

      expect(result.items, isEmpty);
    });

    test(
      'keeps non-newPost notifications and filters only new_post_by_followed',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              'data': {
                'items': [tFollowJson, tNewPostJson],
                'unread_count': 2,
                'pagination': {'has_next': false},
              },
            },
          ),
        );

        final result = await datasource.getNotifications();

        expect(result.items.length, 1);
        expect(result.items.first.type, NotificationType.follow);
      },
    );

    test('defaults unread_count to 0 when key is absent', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'data': <String, dynamic>{
              'items': <dynamic>[],
              'pagination': <String, dynamic>{},
            },
          },
        ),
      );

      final result = await datasource.getNotifications();

      expect(result.unreadCount, 0);
      expect(result.hasNext, false);
    });

    test('handles empty items list', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {
              'items': [],
              'unread_count': 0,
              'pagination': {'has_next': false},
            },
          },
        ),
      );

      final result = await datasource.getNotifications(page: 2, limit: 5);

      expect(result.items, isEmpty);
    });
  });

  group('getUnreadCount', () {
    test(
      'performs GET /notifications/unread-count and returns count',
      () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              'data': {'unread_count': 5},
            },
          ),
        );

        final result = await datasource.getUnreadCount();

        expect(result, 5);
        verify(() => mockDio.get('/notifications/unread-count')).called(1);
      },
    );
  });

  group('markNotificationAsRead', () {
    test('performs PATCH /notifications/{id}/read', () async {
      when(() => mockDio.patch(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await datasource.markNotificationAsRead('notif-123');

      verify(() => mockDio.patch('/notifications/notif-123/read')).called(1);
    });
  });

  group('getFollowStatus', () {
    test('returns true when is_following is true', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {'is_following': true},
          },
        ),
      );

      final result = await datasource.getFollowStatus('user-1');

      expect(result, true);
      verify(() => mockDio.get('/users/user-1/follow-status')).called(1);
    });

    test('returns false when is_following is false', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {'is_following': false},
          },
        ),
      );

      expect(await datasource.getFollowStatus('user-2'), false);
    });

    test('defaults to false when is_following key is absent', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{'data': <String, dynamic>{}},
        ),
      );

      expect(await datasource.getFollowStatus('user-3'), false);
    });
  });

  group('getTrackIdByCommentId', () {
    test('returns trackId and isLikedByMe', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {'track_id': 'track-abc', 'is_liked_by_me': true},
          },
        ),
      );

      final result = await datasource.getTrackIdByCommentId('comment-1');

      expect(result.trackId, 'track-abc');
      expect(result.isLikedByMe, true);
      verify(() => mockDio.get('/comments/comment-1')).called(1);
    });

    test('handles null track_id', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': {'is_liked_by_me': false},
          },
        ),
      );

      final result = await datasource.getTrackIdByCommentId('comment-2');

      expect(result.trackId, isNull);
      expect(result.isLikedByMe, false);
    });

    test('defaults isLikedByMe to false when key is absent', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{'data': <String, dynamic>{}},
        ),
      );

      final result = await datasource.getTrackIdByCommentId('comment-3');

      expect(result.isLikedByMe, false);
    });
  });
}
