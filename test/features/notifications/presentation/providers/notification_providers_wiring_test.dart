import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockNotificationsRepo extends Mock
    implements NotificationsRepoInterface {}

class MockToggleCommentLikeUseCase extends Mock
    implements ToggleCommentLikeUseCase {}

class MockDataSourcesSockets extends Mock implements DataSourcesSockets {}

class MockAuthNotifier extends AuthNotifier with Mock {
  final AuthState _initial;
  MockAuthNotifier(this._initial);
  @override
  AuthState build() => _initial;
}

class FakeFollowStateNotifier extends FollowStateNotifier {
  FakeFollowStateNotifier(GetFollowStatusUsecase usecase) : super(usecase);
}

// ---------------------------------------------------------------------------

void main() {
  late MockNotificationsRepo mockRepo;
  late MockToggleCommentLikeUseCase mockToggleCommentLike;

  setUp(() {
    mockRepo = MockNotificationsRepo();
    mockToggleCommentLike = MockToggleCommentLikeUseCase();
  });

  // =========================================================================
  // notificationsProvider factory
  // =========================================================================

  group('notificationsProvider factory', () {
    test('builds NotificationsNotifier when dependencies are overridden', () {
      final container = ProviderContainer(
        overrides: [
          repositoryprovider.overrideWithValue(mockRepo),
          toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);

      expect(notifier, isA<NotificationsNotifier>());
      expect(container.read(notificationsProvider).items, isEmpty);
    });
  });

  // =========================================================================
  // followStateProvider factory
  // =========================================================================

  group('followStateProvider factory', () {
    test(
      'builds FollowStateNotifier when repositoryprovider is overridden',
      () {
        final container = ProviderContainer(
          overrides: [repositoryprovider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(followStateProvider.notifier);

        expect(notifier, isA<FollowStateNotifier>());
        expect(container.read(followStateProvider), isEmpty);
      },
    );
  });

  // =========================================================================
  // notificationSocketProvider
  // =========================================================================

  group('notificationSocketProvider', () {
    test('returns early without error when user is not authenticated', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => MockAuthNotifier(const AuthUnauthenticated()),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(() => container.read(notificationSocketProvider), returnsNormally);
    });

    test('registers socket callbacks when user is authenticated', () {
      final mockSocket = MockDataSourcesSockets();
      when(() => mockSocket.onNotificationCreated(any())).thenReturn(null);
      when(() => mockSocket.onNotificationRead(any())).thenReturn(null);

      final tUser = const UserEntity(
        id: 'u1',
        displayName: 'Alice',
        email: 'alice@example.com',
        username: 'alice',
        isEmailVerified: true,
      );

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => MockAuthNotifier(AuthAuthenticated(tUser)),
          ),
          socketProvider.overrideWithValue(mockSocket),
          repositoryprovider.overrideWithValue(mockRepo),
          toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
        ],
      );
      addTearDown(container.dispose);

      container.read(notificationSocketProvider);

      verify(() => mockSocket.onNotificationCreated(any())).called(1);
      verify(() => mockSocket.onNotificationRead(any())).called(1);
    });
  });
}
