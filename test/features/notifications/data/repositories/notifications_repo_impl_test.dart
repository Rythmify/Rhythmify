import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/notifications/data/datasources/notification_remote_datasources.dart';
import 'package:rythmify/features/notifications/data/models/notification_model.dart';
import 'package:rythmify/features/notifications/data/repositories/notifications_repo_impl.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

class MockNotificationRemoteDatasources extends Mock
    implements NotificationRemoteDatasources {}

void main() {
  late NotificationsRepoImpl repo;
  late MockNotificationRemoteDatasources mockDatasource;

  final tModel = NotificationModel(
    id: 'n1',
    type: NotificationType.follow,
    actorId: 'u1',
    actorDisplayName: 'Alice',
    isRead: false,
    createdAt: DateTime(2024, 1, 15),
  );

  setUp(() {
    mockDatasource = MockNotificationRemoteDatasources();
    repo = NotificationsRepoImpl(mockDatasource);
  });

  group('NotificationsRepoImpl', () {
    test(
      'getNotifications delegates to datasource and returns result',
      () async {
        when(
          () => mockDatasource.getNotifications(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            unreadOnly: any(named: 'unreadOnly'),
            type: any(named: 'type'),
          ),
        ).thenAnswer(
          (_) async => (items: [tModel], unreadCount: 2, hasNext: true),
        );

        final result = await repo.getNotifications(page: 1, limit: 20);

        expect(result.items, [tModel]);
        expect(result.unreadCount, 2);
        expect(result.hasNext, true);
        verify(
          () => mockDatasource.getNotifications(page: 1, limit: 20),
        ).called(1);
      },
    );

    test('getNotifications passes optional params to datasource', () async {
      when(
        () => mockDatasource.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          unreadOnly: any(named: 'unreadOnly'),
          type: any(named: 'type'),
        ),
      ).thenAnswer(
        (_) async =>
            (items: <NotificationModel>[], unreadCount: 0, hasNext: false),
      );

      await repo.getNotifications(
        page: 2,
        limit: 10,
        unreadOnly: true,
        type: 'like',
      );

      verify(
        () => mockDatasource.getNotifications(
          page: 2,
          limit: 10,
          unreadOnly: true,
          type: 'like',
        ),
      ).called(1);
    });

    test('getUnreadCount delegates to datasource', () async {
      when(() => mockDatasource.getUnreadCount()).thenAnswer((_) async => 7);

      final result = await repo.getUnreadCount();

      expect(result, 7);
      verify(() => mockDatasource.getUnreadCount()).called(1);
    });

    test('markNotificationAsRead delegates to datasource', () async {
      when(
        () => mockDatasource.markNotificationAsRead(any()),
      ).thenAnswer((_) async {});

      await repo.markNotificationAsRead('notif-1');

      verify(() => mockDatasource.markNotificationAsRead('notif-1')).called(1);
    });

    test('getFollowStatus delegates to datasource and returns bool', () async {
      when(
        () => mockDatasource.getFollowStatus(any()),
      ).thenAnswer((_) async => true);

      final result = await repo.getFollowStatus('user-1');

      expect(result, true);
      verify(() => mockDatasource.getFollowStatus('user-1')).called(1);
    });

    test('getTrackIdByCommentId delegates to datasource', () async {
      when(
        () => mockDatasource.getTrackIdByCommentId(any()),
      ).thenAnswer((_) async => (trackId: 'track-1', isLikedByMe: false));

      final result = await repo.getTrackIdByCommentId('comment-1');

      expect(result.trackId, 'track-1');
      expect(result.isLikedByMe, false);
      verify(() => mockDatasource.getTrackIdByCommentId('comment-1')).called(1);
    });
  });
}
