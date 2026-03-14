import '../repositories/track_repository.dart';

class ToggleRepost {
  final TrackRepository repository;

  ToggleRepost(this.repository);

  Future<void> call(String id, bool isCurrentlyReposted) async {
    if (id.isEmpty) return;
    await repository.toggleRepost(id, !isCurrentlyReposted);
  }
}