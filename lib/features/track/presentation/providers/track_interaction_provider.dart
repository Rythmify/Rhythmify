import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'track_dependency_providers.dart';

final trackInteractionProvider = Provider((ref) => TrackInteractionNotifier(ref));

class TrackInteractionNotifier {
  final Ref _ref;

  TrackInteractionNotifier(this._ref);

  Future<void> handleToggleLike(String trackId, bool isCurrentlyLiked) async {
    try {
      final toggleLike = _ref.read(toggleLikeUseCaseProvider);
      
      await toggleLike.call(trackId, isCurrentlyLiked);
      
    } catch (e) {
      // Handle error
    }
  }

  Future<void> handleToggleRepost(String trackId, bool isCurrentlyReposted) async {
    try {
      final toggleRepost = _ref.read(toggleRepostUseCaseProvider);
      await toggleRepost.call(trackId, isCurrentlyReposted);
    } catch (e) {
      // Handle error
    }
  }
}