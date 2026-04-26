import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';

class TrackSyncNotifier extends Notifier<Map<String, Track>> {
  @override
  Map<String, Track> build() {
    return {};
  }

  void syncTrack(Track track) {
    Future.microtask(() {
      state = {...state, track.id: track};
    });
  }

  void toggleLike(String trackId, bool isCurrentlyLiked, Track? currentTrack) {
    final track = state[trackId] ?? currentTrack;
    if (track == null) return;

    final updatedTrack = track.copyWith(
      isLiked: !isCurrentlyLiked,
      likeCount: !isCurrentlyLiked
          ? track.likeCount + 1
          : (track.likeCount - 1).clamp(0, 999999999),
    );

    state = {...state, trackId: updatedTrack};
  }

  void toggleRepost(
    String trackId,
    bool isCurrentlyReposted,
    Track? currentTrack,
  ) {
    final track = state[trackId] ?? currentTrack;
    if (track == null) return;

    final updatedTrack = track.copyWith(
      isReposted: !isCurrentlyReposted,
      repostCount: !isCurrentlyReposted
          ? track.repostCount + 1
          : (track.repostCount - 1).clamp(0, 999999999),
    );

    state = {...state, trackId: updatedTrack};
  }

  void updateCommentCount(String trackId, int newCount, Track? currentTrack) {
    final track = state[trackId] ?? currentTrack;
    if (track == null) return;

    final updatedTrack = track.copyWith(commentCount: newCount);
    state = {...state, trackId: updatedTrack};
  }
}

final trackSyncProvider =
    NotifierProvider<TrackSyncNotifier, Map<String, Track>>(() {
      return TrackSyncNotifier();
    });

final syncedTrackProvider = Provider.family<Track, Track>((ref, track) {
  final map = ref.watch(trackSyncProvider);
  final synced = map[track.id];
  if (synced != null) return synced;
  return track;
});
