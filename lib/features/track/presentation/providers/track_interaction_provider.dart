import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'track_dependency_providers.dart';

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
  Future<void> handleToggleLike(String trackId, bool isCurrentlyLiked) async {
    try {
      final toggleLike = _ref.read(toggleLikeUseCaseProvider);
      await toggleLike.call(trackId, isCurrentlyLiked);
    } catch (e) {
      // Handle error
    }
  }

  /// Handles the user's request to toggle the 'repost' status of a track.
  ///
  /// Calls [toggleRepostUseCaseProvider] to update the track state.
  /// Side effects: Synchronizes the change with [TrackRepository].
  Future<void> handleToggleRepost(
    String trackId,
    bool isCurrentlyReposted,
  ) async {
    try {
      final toggleRepost = _ref.read(toggleRepostUseCaseProvider);
      await toggleRepost.call(trackId, isCurrentlyReposted);
    } catch (e) {
      // Handle error
    }
  }
}
