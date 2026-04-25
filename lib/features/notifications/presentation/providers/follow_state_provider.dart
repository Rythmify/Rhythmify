import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';

class FollowStateNotifier extends StateNotifier<Map<String, bool>> {
    final GetFollowStatusUsecase _getFollowStatus;

    FollowStateNotifier(this._getFollowStatus) : super({});

    Future<void> fetchFollowState(String userId) async {
      try {
        final isFollowing = await _getFollowStatus(userId);
        state = {...state, userId: isFollowing};
      } catch (_) {}
    }

    void setFollowing(String userId, {required bool isFollowing}) {
      state = {...state, userId: isFollowing};
    }
  }

  final followStateProvider =
      StateNotifierProvider<FollowStateNotifier, Map<String, bool>>((ref) {
    final repo = ref.read(repositoryprovider);
    return FollowStateNotifier(GetFollowStatusUsecase(repo));
  });