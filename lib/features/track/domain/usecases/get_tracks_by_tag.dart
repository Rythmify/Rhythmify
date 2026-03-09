import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetTracksByTag {
  final TrackRepository repository;

  GetTracksByTag(this.repository);

  Future<List<Track>> call(String tag) async {
    
    // Ensuring the tag always starts with a hash
    final formattedTag = tag.startsWith('#') ? tag : '#$tag';
    return await repository.getTracksByTag(formattedTag);
  }
}