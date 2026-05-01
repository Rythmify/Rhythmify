import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_track_id_by_comment_id_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';

/// Mock for [NotificationsRepoInterface] used to isolate all notification use cases.
class MockNotificationsRepo extends Mock
    implements NotificationsRepoInterface {}

/// Shared notification fixture used across multiple use case tests.
final tNotification = NotificationEntity(
  id: 'n1',
  type: NotificationType.follow,
  actorId: 'u1',
  actorDisplayName: 'Alice',
  isRead: false,
  createdAt: DateTime(2024, 1, 15),
);

/// Tests for all notification use cases.
///
/// Covers [GetNotificationsUsecase], [GetUnreadCountUsecase],
/// [MarkNotificationAsReadUsecase], [GetFollowStatusUsecase], and
/// [GetTrackIdByCommentIdUsecase] — each verified for parameter delegation
/// and return value propagation with no added logic.
void main() {
  late MockNotificationsRepo mockRepo;

  setUp(() {
    mockRepo = MockNotificationsRepo();
  });

  group('GetNotificationsUsecase', () {
    late GetNotificationsUsecase usecase;

    setUp(() => usecase = GetNotificationsUsecase(mockRepo));

    test('returns result from repo with supplied params', () async {
      when(
        () => mockRepo.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          unreadOnly: any(named: 'unreadOnly'),
          type: any(named: 'type'),
        ),
      ).thenAnswer(
        (_) async => (items: [tNotification], unreadCount: 1, hasNext: false),
      );

      final result = await usecase(page: 2, limit: 10, type: 'follow');

      expect(result.items, [tNotification]);
      expect(result.unreadCount, 1);
      expect(result.hasNext, false);
      verify(
        () => mockRepo.getNotifications(page: 2, limit: 10, type: 'follow'),
      ).called(1);
    });

    test('uses default page=1 limit=20 when no params supplied', () async {
      when(
        () => mockRepo.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          unreadOnly: any(named: 'unreadOnly'),
          type: any(named: 'type'),
        ),
      ).thenAnswer(
        (_) async =>
            (items: <NotificationEntity>[], unreadCount: 0, hasNext: false),
      );

      await usecase();

      verify(() => mockRepo.getNotifications(page: 1, limit: 20)).called(1);
    });

    test('propagates repository exceptions', () async {
      when(
        () => mockRepo.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          unreadOnly: any(named: 'unreadOnly'),
          type: any(named: 'type'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(() => usecase(), throwsException);
    });
  });

  group('GetUnreadCountUsecase', () {
    late GetUnreadCountUsecase usecase;

    setUp(() => usecase = GetUnreadCountUsecase(mockRepo));

    test('returns unread count from repo', () async {
      when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => 5);

      final result = await usecase();

      expect(result, 5);
      verify(() => mockRepo.getUnreadCount()).called(1);
    });

    test('returns 0 when repo returns 0', () async {
      when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => 0);

      expect(await usecase(), 0);
    });
  });

  group('MarkNotificationAsReadUsecase', () {
    late MarkNotificationAsReadUsecase usecase;

    setUp(() => usecase = MarkNotificationAsReadUsecase(mockRepo));

    test('calls repo.markNotificationAsRead with correct id', () async {
      when(
        () => mockRepo.markNotificationAsRead(any()),
      ).thenAnswer((_) async {});

      await usecase('notif-123');

      verify(() => mockRepo.markNotificationAsRead('notif-123')).called(1);
    });

    test('propagates exceptions from repo', () {
      when(
        () => mockRepo.markNotificationAsRead(any()),
      ).thenThrow(Exception('Server error'));

      expect(() => usecase('notif-err'), throwsException);
    });
  });

  group('GetFollowStatusUsecase', () {
    late GetFollowStatusUsecase usecase;

    setUp(() => usecase = GetFollowStatusUsecase(mockRepo));

    test('returns true when user is followed', () async {
      when(() => mockRepo.getFollowStatus(any())).thenAnswer((_) async => true);

      final result = await usecase('user-123');

      expect(result, true);
      verify(() => mockRepo.getFollowStatus('user-123')).called(1);
    });

    test('returns false when user is not followed', () async {
      when(
        () => mockRepo.getFollowStatus(any()),
      ).thenAnswer((_) async => false);

      final result = await usecase('user-456');

      expect(result, false);
      verify(() => mockRepo.getFollowStatus('user-456')).called(1);
    });
  });

  group('GetTrackIdByCommentIdUsecase', () {
    late GetTrackIdByCommentIdUsecase usecase;

    setUp(() => usecase = GetTrackIdByCommentIdUsecase(mockRepo));

    test('returns trackId and isLikedByMe from repo', () async {
      when(
        () => mockRepo.getTrackIdByCommentId(any()),
      ).thenAnswer((_) async => (trackId: 'track-999', isLikedByMe: true));

      final result = await usecase('comment-abc');

      expect(result.trackId, 'track-999');
      expect(result.isLikedByMe, true);
      verify(() => mockRepo.getTrackIdByCommentId('comment-abc')).called(1);
    });

    test('handles null trackId', () async {
      when(
        () => mockRepo.getTrackIdByCommentId(any()),
      ).thenAnswer((_) async => (trackId: null, isLikedByMe: false));

      final result = await usecase('comment-xyz');

      expect(result.trackId, isNull);
      expect(result.isLikedByMe, false);
    });
  });
}
