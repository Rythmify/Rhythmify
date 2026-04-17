import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import 'track_dependency_providers.dart';
import 'track_sync_provider.dart';

/// [trackInteractionProvider] provides an instance of [TrackInteractionNotifier].
///
/// This provider handles user interactions related to track mutations.
/// Layer: Presentation
final trackInteractionProvider = Provider(
  (ref) => TrackInteractionNotifier(ref),
);

/// [TrackInteractionNotifier] manages user interactions with track entities.
///
/// It acts as a bridge between the UI and mutation use cases, facilitating
/// actions like liking and reposting tracks.
class TrackInteractionNotifier {
  final Ref _ref;

  TrackInteractionNotifier(this._ref);

  /// Handles the user's request to toggle the 'like' status of a track.
  ///
  /// Calls [toggleLikeUseCaseProvider] to update the track state.
  /// Side effects: Updates the remote/local state via [TrackRepository].
  Future<void> handleToggleLike(
    String trackId,
    bool isCurrentlyLiked, {
    Track? currentTrack,
  }) async {
    try {
      // Instantly update the UI via the global sync provider
      _ref
          .read(trackSyncProvider.notifier)
          .toggleLike(trackId, isCurrentlyLiked, currentTrack);

      final toggleLike = _ref.read(toggleLikeUseCaseProvider);
      // We pass !isCurrentlyLiked because we want to set it to the opposite state
      await toggleLike.call(trackId, !isCurrentlyLiked);
    } catch (e) {
      // If it fails, revert the optimistic update
      _ref
          .read(trackSyncProvider.notifier)
          .toggleLike(trackId, !isCurrentlyLiked, null);
    }
  }

  /// Handles the user's request to toggle the 'repost' status of a track.
  ///
  /// Calls [toggleRepostUseCaseProvider] to update the track state.
  /// Side effects: Synchronizes the change with [TrackRepository].
  Future<void> handleToggleRepost(
    String trackId,
    bool isCurrentlyReposted, {
    Track? currentTrack,
  }) async {
    try {
      // Instantly update the UI via the global sync provider
      _ref
          .read(trackSyncProvider.notifier)
          .toggleRepost(trackId, isCurrentlyReposted, currentTrack);

      final toggleRepost = _ref.read(toggleRepostUseCaseProvider);
      // We pass !isCurrentlyReposted because we want to set it to the opposite state
      await toggleRepost.call(trackId, !isCurrentlyReposted);
    } catch (e) {
      // If it fails, revert the optimistic update
      _ref
          .read(trackSyncProvider.notifier)
          .toggleRepost(trackId, !isCurrentlyReposted, null);
    }
  }
}
