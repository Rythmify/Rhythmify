import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:rythmify/features/profile/domain/usecases/get_follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unfollow_user_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGetNotificationsUsecase extends Mock
    implements GetNotificationsUsecase {}

class MockGetUnreadCountUsecase extends Mock implements GetUnreadCountUsecase {}

class MockMarkNotificationAsReadUsecase extends Mock
    implements MarkNotificationAsReadUsecase {}

class MockGetFollowUserUseCase extends Mock implements GetFollowUserUseCase {}

class MockGetUnfollowUserUseCase extends Mock
    implements GetUnfollowUserUseCase {}

class MockToggleCommentLikeUseCase extends Mock
    implements ToggleCommentLikeUseCase {}

class MockNotificationsRepo extends Mock
    implements NotificationsRepoInterface {}

// ---------------------------------------------------------------------------
// Fake FollowStateNotifier — records calls without real I/O
// ---------------------------------------------------------------------------

class FakeFollowStateNotifier extends FollowStateNotifier {
  final List<String> fetchedIds = [];
  final List<MapEntry<String, bool>> setFollowingCalls = [];

  FakeFollowStateNotifier(super.usecase);

  @override
  Future<void> fetchFollowState(String userId) async {
    fetchedIds.add(userId);
  }

  @override
  void setFollowing(String userId, {required bool isFollowing}) {
    setFollowingCalls.add(MapEntry(userId, isFollowing));
    state = {...state, userId: isFollowing};
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final tCreatedAt = DateTime(2024, 1, 15);

final tFollowNotif = NotificationEntity(
  id: 'n-follow',
  type: NotificationType.follow,
  actorId: 'actor-1',
  actorDisplayName: 'Alice',
  isRead: false,
  createdAt: tCreatedAt,
);

final tLikeNotif = NotificationEntity(
  id: 'n-like',
  type: NotificationType.like,
  actorId: 'actor-2',
  actorDisplayName: 'Bob',
  isRead: true,
  createdAt: tCreatedAt,
);

({List<NotificationEntity> items, int unreadCount, bool hasNext}) _page(
  List<NotificationEntity> items, {
  int unread = 0,
  bool hasNext = false,
}) => (items: items, unreadCount: unread, hasNext: hasNext);

({List<NotificationEntity> items, int unreadCount, bool hasNext})
_emptyPage() => (items: <NotificationEntity>[], unreadCount: 0, hasNext: false);

// ---------------------------------------------------------------------------

void main() {
  late MockGetNotificationsUsecase mockGetNotifications;
  late MockGetUnreadCountUsecase mockGetUnreadCount;
  late MockMarkNotificationAsReadUsecase mockMarkRead;
  late MockGetFollowUserUseCase mockFollow;
  late MockGetUnfollowUserUseCase mockUnfollow;
  late MockToggleCommentLikeUseCase mockToggleCommentLike;
  late FakeFollowStateNotifier fakeFollowState;
  late MockNotificationsRepo mockRepo;
  late NotificationsNotifier notifier;

  NotificationsNotifier buildNotifier() => NotificationsNotifier(
    getNotifications: mockGetNotifications,
    getUnreadCount: mockGetUnreadCount,
    markAllRead: mockMarkRead,
    followUser: mockFollow,
    unfollowUser: mockUnfollow,
    toggleCommentLike: mockToggleCommentLike,
    followState: fakeFollowState,
  );

  setUp(() {
    mockGetNotifications = MockGetNotificationsUsecase();
    mockGetUnreadCount = MockGetUnreadCountUsecase();
    mockMarkRead = MockMarkNotificationAsReadUsecase();
    mockFollow = MockGetFollowUserUseCase();
    mockUnfollow = MockGetUnfollowUserUseCase();
    mockToggleCommentLike = MockToggleCommentLikeUseCase();
    mockRepo = MockNotificationsRepo();
    fakeFollowState = FakeFollowStateNotifier(GetFollowStatusUsecase(mockRepo));
    notifier = buildNotifier();

    when(() => mockMarkRead(any())).thenAnswer((_) async {});
  });

  // =========================================================================
  // NotificationsState
  // =========================================================================

  group('NotificationsState', () {
    test('has correct default values', () {
      const s = NotificationsState();
      expect(s.items, isEmpty);
      expect(s.unreadCount, 0);
      expect(s.isLoading, false);
      expect(s.isLoadingMore, false);
      expect(s.hasNext, false);
      expect(s.currentPage, 0);
      expect(s.error, isNull);
      expect(s.likedCommentIds, isEmpty);
    });

    group('copyWith', () {
      test('updates individual scalar fields', () {
        const s = NotificationsState();
        final u = s.copyWith(unreadCount: 3, isLoading: true, currentPage: 2);
        expect(u.unreadCount, 3);
        expect(u.isLoading, true);
        expect(u.currentPage, 2);
        expect(u.isLoadingMore, false);
      });

      test('clearError: true sets error to null regardless of error param', () {
        const s = NotificationsState(error: 'old error');
        final u = s.copyWith(error: 'new', clearError: true);
        expect(u.error, isNull);
      });

      test('error param updates error when clearError is false (default)', () {
        const s = NotificationsState();
        final u = s.copyWith(error: 'Something went wrong');
        expect(u.error, 'Something went wrong');
      });

      test(
        'error is preserved when neither error nor clearError is supplied',
        () {
          const s = NotificationsState(error: 'preserved');
          final u = s.copyWith(isLoading: true);
          expect(u.error, 'preserved');
        },
      );

      test('updates likedCommentIds', () {
        const s = NotificationsState();
        final u = s.copyWith(likedCommentIds: {'c1', 'c2'});
        expect(u.likedCommentIds, {'c1', 'c2'});
      });

      test('updates items list', () {
        const s = NotificationsState();
        final u = s.copyWith(items: [tFollowNotif]);
        expect(u.items, [tFollowNotif]);
      });
    });
  });

  // =========================================================================
  // NotificationsNotifier
  // =========================================================================

  group('NotificationsNotifier', () {
    test('initial state is default', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.unreadCount, 0);
    });

    // -----------------------------------------------------------------------
    // fetch
    // -----------------------------------------------------------------------

    group('fetch', () {
      test(
        'populates items, unreadCount, hasNext, and currentPage on success',
        () async {
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer(
            (_) async =>
                _page([tFollowNotif, tLikeNotif], unread: 1, hasNext: true),
          );

          await notifier.fetch();

          final s = notifier.state;
          expect(s.isLoading, false);
          expect(s.items, [tFollowNotif, tLikeNotif]);
          expect(s.unreadCount, 1);
          expect(s.hasNext, true);
          expect(s.currentPage, 1);
          expect(s.error, isNull);
        },
      );

      test('clears existing items and error before loading', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenThrow(Exception('First error'));
        await notifier.fetch();
        expect(notifier.state.error, isNotNull);

        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([tLikeNotif]));
        await notifier.fetch();

        expect(notifier.state.error, isNull);
        expect(notifier.state.items, [tLikeNotif]);
      });

      test('fires markRead for each unread notification', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([tFollowNotif])); // isRead: false

        await notifier.fetch();
        await Future.delayed(Duration.zero);

        verify(() => mockMarkRead(tFollowNotif.id)).called(1);
      });

      test('does not fire markRead for already-read notifications', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([tLikeNotif])); // isRead: true

        await notifier.fetch();
        await Future.delayed(Duration.zero);

        verifyNever(() => mockMarkRead(any()));
      });

      test('seeds followState for follow-type notifications', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([tFollowNotif]));

        await notifier.fetch();

        expect(fakeFollowState.fetchedIds, contains('actor-1'));
      });

      test('does not seed followState for non-follow notifications', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([tLikeNotif]));

        await notifier.fetch();

        expect(fakeFollowState.fetchedIds, isEmpty);
      });

      test('sets error and clears isLoading on exception', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenThrow(Exception('Network error'));

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Network error'));
      });

      test('stores the active type filter and passes it to usecase', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _emptyPage());

        await notifier.fetch(type: 'like');

        verify(() => mockGetNotifications(page: 1, type: 'like')).called(1);
      });
    });

    // -----------------------------------------------------------------------
    // loadMore
    // -----------------------------------------------------------------------

    group('loadMore', () {
      test('does nothing when hasNext is false', () async {
        await notifier.loadMore();

        verifyNever(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        );
      });

      test('appends items and increments currentPage', () async {
        when(
          () => mockGetNotifications(page: 1, type: any(named: 'type')),
        ).thenAnswer((_) async => _page([tLikeNotif], hasNext: true));
        await notifier.fetch();

        when(
          () => mockGetNotifications(page: 2, type: any(named: 'type')),
        ).thenAnswer((_) async => _page([tFollowNotif], hasNext: false));
        await notifier.loadMore();

        expect(notifier.state.items.length, 2);
        expect(notifier.state.currentPage, 2);
        expect(notifier.state.hasNext, false);
        expect(notifier.state.isLoadingMore, false);
      });

      test('fires markRead for new unread items in loaded page', () async {
        when(
          () => mockGetNotifications(page: 1, type: any(named: 'type')),
        ).thenAnswer((_) async => _page([tLikeNotif], hasNext: true));
        await notifier.fetch();
        clearInteractions(mockMarkRead);
        when(() => mockMarkRead(any())).thenAnswer((_) async {});

        when(
          () => mockGetNotifications(page: 2, type: any(named: 'type')),
        ).thenAnswer((_) async => _page([tFollowNotif])); // isRead: false
        await notifier.loadMore();
        await Future.delayed(Duration.zero);

        verify(() => mockMarkRead(tFollowNotif.id)).called(1);
      });

      test('seeds followState for follow-type actors in loaded page', () async {
        when(
          () => mockGetNotifications(page: 1, type: any(named: 'type')),
        ).thenAnswer(
          (_) async =>
              (items: <NotificationEntity>[], unreadCount: 0, hasNext: true),
        );
        await notifier.fetch();
        fakeFollowState.fetchedIds.clear();

        when(
          () => mockGetNotifications(page: 2, type: any(named: 'type')),
        ).thenAnswer((_) async => _page([tFollowNotif]));
        await notifier.loadMore();

        expect(fakeFollowState.fetchedIds, contains('actor-1'));
      });

      test(
        'sets isLoadingMore to false and preserves page on exception',
        () async {
          when(
            () => mockGetNotifications(page: 1, type: any(named: 'type')),
          ).thenAnswer((_) async => _page([tLikeNotif], hasNext: true));
          await notifier.fetch();
          final pageBefore = notifier.state.currentPage;

          when(
            () => mockGetNotifications(page: 2, type: any(named: 'type')),
          ).thenThrow(Exception('Load failed'));
          await notifier.loadMore();

          expect(notifier.state.isLoadingMore, false);
          expect(notifier.state.currentPage, pageBefore);
        },
      );
    });

    // -----------------------------------------------------------------------
    // toggleFollow
    // -----------------------------------------------------------------------

    group('toggleFollow', () {
      test('optimistically sets following to opposite of current state', () {
        when(
          () => mockUnfollow(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        notifier.toggleFollow(
          'actor-1',
          true,
        ); // currently following → optimistically unfollow

        expect(fakeFollowState.setFollowingCalls.first.key, 'actor-1');
        expect(fakeFollowState.setFollowingCalls.first.value, false);
      });

      test('calls unfollow usecase when currently following', () async {
        when(
          () => mockUnfollow(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        await notifier.toggleFollow('actor-1', true);

        verify(() => mockUnfollow(userId: 'actor-1')).called(1);
        verifyNever(() => mockFollow(userId: any(named: 'userId')));
      });

      test('calls follow usecase when currently NOT following', () async {
        when(
          () => mockFollow(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        await notifier.toggleFollow('actor-1', false);

        verify(() => mockFollow(userId: 'actor-1')).called(1);
        verifyNever(() => mockUnfollow(userId: any(named: 'userId')));
      });

      test('reverts to original state on Left (failure) result', () async {
        when(
          () => mockUnfollow(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Left(const ServerFailure('Unfollow failed')));

        await notifier.toggleFollow('actor-1', true);

        expect(fakeFollowState.setFollowingCalls.length, 2);
        expect(
          fakeFollowState.setFollowingCalls.last.value,
          true,
        ); // reverted to true
      });

      test('reverts on exception from usecase', () async {
        when(
          () => mockFollow(userId: any(named: 'userId')),
        ).thenThrow(Exception('Connection error'));

        await notifier.toggleFollow('actor-1', false);

        expect(
          fakeFollowState.setFollowingCalls.last.value,
          false,
        ); // reverted to false
      });

      test('keeps change when Right (success) result', () async {
        when(
          () => mockFollow(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        await notifier.toggleFollow('actor-1', false);

        // Only one call (optimistic), never reverted
        expect(fakeFollowState.setFollowingCalls.length, 1);
        expect(fakeFollowState.setFollowingCalls.first.value, true);
      });
    });

    // -----------------------------------------------------------------------
    // toggleCommentLike
    // -----------------------------------------------------------------------

    group('toggleCommentLike', () {
      test(
        'adds commentId to likedCommentIds when not currently liked',
        () async {
          when(
            () => mockToggleCommentLike(
              any(),
              isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
            ),
          ).thenAnswer((_) async => true);

          await notifier.toggleCommentLike('comment-1', false);

          expect(notifier.state.likedCommentIds, contains('comment-1'));
        },
      );

      test(
        'removes commentId from likedCommentIds when currently liked',
        () async {
          when(
            () => mockToggleCommentLike(
              any(),
              isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
            ),
          ).thenAnswer((_) async => false);

          await notifier.toggleCommentLike('comment-1', false);
          await notifier.toggleCommentLike('comment-1', true);

          expect(notifier.state.likedCommentIds, isNot(contains('comment-1')));
        },
      );

      test('reverts optimistic change on exception', () async {
        when(
          () => mockToggleCommentLike(
            any(),
            isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
          ),
        ).thenThrow(Exception('Like failed'));

        await notifier.toggleCommentLike('comment-1', false);

        expect(notifier.state.likedCommentIds, isNot(contains('comment-1')));
      });

      test(
        'preserves other liked comments when reverting a failed like',
        () async {
          when(
            () => mockToggleCommentLike(
              any(),
              isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
            ),
          ).thenAnswer((_) async => true);
          await notifier.toggleCommentLike('comment-good', false);

          when(
            () => mockToggleCommentLike(
              any(),
              isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
            ),
          ).thenThrow(Exception('Like failed'));
          await notifier.toggleCommentLike('comment-bad', false);

          expect(notifier.state.likedCommentIds, contains('comment-good'));
          expect(
            notifier.state.likedCommentIds,
            isNot(contains('comment-bad')),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // onSocketNotificationCreated
    // -----------------------------------------------------------------------

    group('onSocketNotificationCreated', () {
      test('increments unreadCount immediately', () {
        expect(notifier.state.unreadCount, 0);
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _emptyPage());

        notifier.onSocketNotificationCreated({});

        expect(notifier.state.unreadCount, 1);
      });

      test(
        'prepends parsed notification to items when payload is valid and no type filter',
        () async {
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer((_) async => _emptyPage());
          await notifier.fetch(); // activeType remains null

          notifier.onSocketNotificationCreated({
            'notification': {
              'id': 'socket-n1',
              'type': 'follow',
              'actor': {'id': 'u99', 'display_name': 'Charlie'},
              'is_read': false,
              'created_at': '2024-01-15T10:30:00.000Z',
            },
          });

          expect(notifier.state.items.first.id, 'socket-n1');
        },
      );

      test(
        'falls back to silent refresh when notification key is absent',
        () async {
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer((_) async => _page([tLikeNotif]));
          await notifier.fetch();

          clearInteractions(mockGetNotifications);
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer((_) async => _emptyPage());

          // No 'notification' key → cast to Map throws → silent refresh
          notifier.onSocketNotificationCreated({'other_key': 'data'});
          await Future.delayed(Duration.zero);

          verify(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).called(greaterThanOrEqualTo(1));
        },
      );

      test(
        'falls back to silent refresh when notification type does not match active filter',
        () async {
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer((_) async => _emptyPage());
          await notifier.fetch(type: 'like'); // activeType = 'like'

          clearInteractions(mockGetNotifications);
          when(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).thenAnswer((_) async => _emptyPage());

          notifier.onSocketNotificationCreated({
            'notification': {
              'id': 'socket-n2',
              'type': 'follow', // does NOT match active filter 'like'
              'actor': {'id': 'u77', 'display_name': 'Dave'},
              'is_read': false,
              'created_at': '2024-01-15T10:30:00.000Z',
            },
          });
          await Future.delayed(Duration.zero);

          verify(
            () => mockGetNotifications(
              page: any(named: 'page'),
              type: any(named: 'type'),
            ),
          ).called(1);
        },
      );
    });

    // -----------------------------------------------------------------------
    // onSocketNotificationRead
    // -----------------------------------------------------------------------

    group('onSocketNotificationRead', () {
      test('decrements unreadCount when count is greater than 0', () async {
        when(
          () => mockGetNotifications(
            page: any(named: 'page'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => _page([], unread: 2));
        await notifier.fetch();
        expect(notifier.state.unreadCount, 2);

        notifier.onSocketNotificationRead();

        expect(notifier.state.unreadCount, 1);
      });

      test('does not decrement below 0 when unreadCount is already 0', () {
        expect(notifier.state.unreadCount, 0);

        notifier.onSocketNotificationRead();

        expect(notifier.state.unreadCount, 0);
      });
    });
  });

  // =========================================================================
  // unreadNotificationsCountProvider
  // =========================================================================

  group('unreadNotificationsCountProvider', () {
    test('exposes unreadCount from notificationsProvider state', () async {
      when(
        () => mockGetNotifications(
          page: any(named: 'page'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => _page([], unread: 7));

      final container = ProviderContainer(
        overrides: [notificationsProvider.overrideWith((_) => notifier)],
      );
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).fetch();

      expect(container.read(unreadNotificationsCountProvider), 7);
    });

    test('reflects 0 when no fetch has occurred', () {
      final container = ProviderContainer(
        overrides: [notificationsProvider.overrideWith((_) => notifier)],
      );
      addTearDown(container.dispose);

      expect(container.read(unreadNotificationsCountProvider), 0);
    });
  });
}
