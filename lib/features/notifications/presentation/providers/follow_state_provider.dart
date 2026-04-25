import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';

/// Lightweight cache of follow states keyed by user ID.
///
/// Stores `Map<userId, isFollowing>` so the notifications screen can show the
/// correct Follow / Following button state without loading full user profiles.
///
/// [fetchFollowState] is called fire-and-forget after each page of notifications
/// loads — one call per unique follow-notification actor.
/// [setFollowing] is used for optimistic UI updates when the user taps the button.
class FollowStateNotifier extends StateNotifier<Map<String, bool>> {
  final GetFollowStatusUsecase _getFollowStatus;

  FollowStateNotifier(this._getFollowStatus) : super({});

  /// Calls `GET /users/{userId}/follow-status` and caches the result.
  /// Silently no-ops on network errors — the button defaults to "Follow".
  Future<void> fetchFollowState(String userId) async {
    try {
      final isFollowing = await _getFollowStatus(userId);
      state = {...state, userId: isFollowing};
    } catch (_) {}
  }

  /// Immediately updates the cached follow state for [userId].
  /// Used for optimistic UI updates; reverted by [NotificationsNotifier.toggleFollow]
  /// if the API call fails.
  void setFollowing(String userId, {required bool isFollowing}) {
    state = {...state, userId: isFollowing};
  }
}

/// Provides the [FollowStateNotifier] and its `Map<userId, isFollowing>` state.
final followStateProvider =
    StateNotifierProvider<FollowStateNotifier, Map<String, bool>>(
      (ref) => FollowStateNotifier(
        GetFollowStatusUsecase(ref.read(repositoryprovider)),
      ),
    );
