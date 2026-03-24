import '../repositories/track_repository.dart';

/// [GetTags] encapsulates the business logic for retrieving all track tags.
///
/// This use case interacts with the [TrackRepository] to fetch a mapping
/// of tag IDs to names, which is used for categorizing tracks.
class GetTags {
  final TrackRepository repository;

  GetTags(this.repository);

  /// Executes the use case to fetch the tags.
  Future<Map<String, String>> call() async {
    return await repository.getTags();
  }
}
