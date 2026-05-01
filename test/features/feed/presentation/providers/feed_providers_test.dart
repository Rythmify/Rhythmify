import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/feed/domain/entities/feed_item.dart';
import 'package:rythmify/features/feed/domain/usecases/get_discover_feed_usecase.dart';
import 'package:rythmify/features/feed/domain/usecases/get_following_feed_usecase.dart';
import 'package:rythmify/features/feed/presentation/providers/feed_providers.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/data/models/user_model.dart';

// ============ Mock AuthNotifier ============
class MockAuthNotifier extends AuthNotifier {
  final AuthState _state;
  MockAuthNotifier(this._state);

  @override
  AuthState build() => _state;
}

// ============ Mock Use Cases ============
class MockGetFollowingFeedUseCase extends Mock
    implements GetFollowingFeedUseCase {}

class MockGetDiscoverFeedUseCase extends Mock
    implements GetDiscoverFeedUseCase {}

// ============ Test Fixtures ============
final tFeedUser = FeedUserEntity(
  id: 'user-1',
  username: 'testuser',
  displayName: 'Test User',
  followers: 1000,
  isVerified: true,
);

final tFeedTrack = FeedTrackEntity(
  id: 'track-1',
  title: 'Test Track',
  duration: 180,
  playCount: 5000,
  likeCount: 500,
  audioUrl: 'https://example.com/audio.mp3',
  uploaderUsername: 'uploader',
);

final tFeedItem = FeedItemEntity(
  id: 'feed-1',
  type: 'post',
  contentType: 'track',
  createdAt: DateTime(2024, 1, 1),
  user: tFeedUser,
  trackOwner: tFeedUser,
  track: tFeedTrack,
);

final tUser = UserModel(
  id: 'user-1',
  email: 'test@test.com',
  displayName: 'Test User',
  isEmailVerified: true,
  token: 'fake-token',
);

void main() {
  group('Feed Providers', () {
    group('followingFeedProvider', () {
      test('executes and returns feed items', () async {
        final container = ProviderContainer(
          overrides: [
            followingFeedProvider.overrideWith((ref) async => [tFeedItem]),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(followingFeedProvider.future);
        expect(result, [tFeedItem]);
        expect(result.length, 1);
      });

      test('returns empty list', () async {
        final container = ProviderContainer(
          overrides: [followingFeedProvider.overrideWith((ref) async => [])],
        );
        addTearDown(container.dispose);

        final result = await container.read(followingFeedProvider.future);
        expect(result, isEmpty);
      });

      test('returns list with multiple items', () async {
        final container = ProviderContainer(
          overrides: [
            followingFeedProvider.overrideWith(
              (ref) async => [tFeedItem, tFeedItem],
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(followingFeedProvider.future);
        expect(result.length, 2);
      });
    });

    group('discoverFeedProvider', () {
      test('returns empty list when user is NOT authenticated', () async {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(const AuthUnauthenticated()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(discoverFeedProvider.future);
        expect(result, isEmpty);
      });

      test('returns empty list for AuthChecking state', () async {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(const AuthChecking()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(discoverFeedProvider.future);
        expect(result, isEmpty);
      });

      test('returns empty list for AuthLoading state', () async {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(const AuthLoading()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(discoverFeedProvider.future);
        expect(result, isEmpty);
      });

      test('executes use case when user IS authenticated', () async {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            discoverFeedProvider.overrideWith((ref) async => [tFeedItem]),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(discoverFeedProvider.future);
        expect(result, [tFeedItem]);
      });

      test('returns list with multiple items when authenticated', () async {
        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            discoverFeedProvider.overrideWith(
              (ref) async => [tFeedItem, tFeedItem],
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(discoverFeedProvider.future);
        expect(result.length, 2);
      });
    });

    group('playerSheetNotifier', () {
      test('starts with null value', () {
        expect(playerSheetNotifier.value, isNull);
      });

      test('can set and invoke a callback', () {
        bool called = false;
        playerSheetNotifier.value = () {
          called = true;
        };
        playerSheetNotifier.value?.call();

        expect(called, isTrue);
        playerSheetNotifier.value = null;
      });

      test('can be reset to null', () {
        playerSheetNotifier.value = () {};
        playerSheetNotifier.value = null;
        expect(playerSheetNotifier.value, isNull);
      });
    });

    group('playerCollapseNotifier', () {
      test('starts with null value', () {
        expect(playerCollapseNotifier.value, isNull);
      });

      test('can set and invoke a callback', () {
        bool called = false;
        playerCollapseNotifier.value = () {
          called = true;
        };
        playerCollapseNotifier.value?.call();

        expect(called, isTrue);
        playerCollapseNotifier.value = null;
      });

      test('can be reset to null', () {
        playerCollapseNotifier.value = () {};
        playerCollapseNotifier.value = null;
        expect(playerCollapseNotifier.value, isNull);
      });
    });

    group('provider independence', () {
      test('followingFeedProvider and discoverFeedProvider are distinct', () {
        expect(followingFeedProvider != discoverFeedProvider, isTrue);
      });

      test('playerSheetNotifier and playerCollapseNotifier are distinct', () {
        expect(playerSheetNotifier != playerCollapseNotifier, isTrue);
      });
    });
  });
}
