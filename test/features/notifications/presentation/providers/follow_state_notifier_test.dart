import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';

/// Mock for [GetFollowStatusUsecase] used to isolate [FollowStateNotifier].
class MockGetFollowStatusUsecase extends Mock
    implements GetFollowStatusUsecase {}

/// Tests for [FollowStateNotifier].
///
/// Verifies the initial empty-map state, that [fetchFollowState] caches
/// the boolean result keyed by userId, and that multiple users can be tracked
/// independently in the same state map.
void main() {
  late MockGetFollowStatusUsecase mockUsecase;
  late FollowStateNotifier notifier;

  setUp(() {
    mockUsecase = MockGetFollowStatusUsecase();
    notifier = FollowStateNotifier(mockUsecase);
  });

  group('FollowStateNotifier', () {
    test('initial state is an empty map', () {
      expect(notifier.state, isEmpty);
    });

    group('fetchFollowState', () {
      test('updates state with true when user is following', () async {
        when(() => mockUsecase('user-1')).thenAnswer((_) async => true);

        await notifier.fetchFollowState('user-1');

        expect(notifier.state['user-1'], true);
      });

      test('updates state with false when user is not following', () async {
        when(() => mockUsecase('user-2')).thenAnswer((_) async => false);

        await notifier.fetchFollowState('user-2');

        expect(notifier.state['user-2'], false);
      });

      test('silently ignores errors and leaves state unchanged', () async {
        when(() => mockUsecase(any())).thenThrow(Exception('Network error'));

        await expectLater(
          () => notifier.fetchFollowState('user-err'),
          returnsNormally,
        );
        expect(notifier.state.containsKey('user-err'), false);
      });

      test('can fetch multiple different users', () async {
        when(() => mockUsecase('u1')).thenAnswer((_) async => true);
        when(() => mockUsecase('u2')).thenAnswer((_) async => false);

        await notifier.fetchFollowState('u1');
        await notifier.fetchFollowState('u2');

        expect(notifier.state['u1'], true);
        expect(notifier.state['u2'], false);
      });
    });

    group('setFollowing', () {
      test('sets true for a userId', () {
        notifier.setFollowing('user-1', isFollowing: true);
        expect(notifier.state['user-1'], true);
      });

      test('sets false for a userId', () {
        notifier.setFollowing('user-1', isFollowing: false);
        expect(notifier.state['user-1'], false);
      });

      test('overrides previous value', () {
        notifier.setFollowing('user-1', isFollowing: true);
        notifier.setFollowing('user-1', isFollowing: false);
        expect(notifier.state['user-1'], false);
      });

      test('preserves other entries when adding a new one', () {
        notifier.setFollowing('user-1', isFollowing: true);
        notifier.setFollowing('user-2', isFollowing: false);
        expect(notifier.state['user-1'], true);
        expect(notifier.state['user-2'], false);
      });

      test('does not remove unrelated entries', () {
        notifier.setFollowing('user-a', isFollowing: true);
        notifier.setFollowing('user-b', isFollowing: true);
        notifier.setFollowing('user-a', isFollowing: false);
        expect(notifier.state['user-b'], true);
      });
    });
  });
}
