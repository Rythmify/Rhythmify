import '../repositories/track_repository.dart';

class GetTags {
  final TrackRepository repository;

  GetTags(this.repository);

  Future<Map<String, String>> call() async {
    return await repository.getTags();
  }
}
