import '../repositories/track_repository.dart';

class ToggleLike {
  final TrackRepository repository;

  ToggleLike(this.repository);

  Future<void> call(String id, bool isCurrentlyLiked) async {
    if (id.isEmpty) return;
    await repository.toggleLike(id, !isCurrentlyLiked);
  }
}