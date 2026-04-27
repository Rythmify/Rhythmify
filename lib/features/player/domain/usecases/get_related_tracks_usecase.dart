import '../../../../core/domain/entities/track.dart';
import '../../../playlist/data/datasources/playlist_remote_datasource.dart';

class GetRelatedTracksUseCase {
  final PlaylistRemoteDatasource datasource;
  GetRelatedTracksUseCase(this.datasource);

  Future<List<Track>> call(String trackId) async {
    final playlistTracks = await datasource.fetchRelatedTracks(trackId);
    
    // Convert PlaylistTrack -> Track
    // Note: This is a bit of a shortcut, ideally we'd have a repository method 
    // that returns Track entities directly.
    return playlistTracks.map((pt) => Track(
      id: pt.id,
      title: pt.title,
      artist: pt.artistName,
      userId: '', // Required but unknown from pt
      audioUrl: pt.audioUrl ?? '', 
      streamUrl: pt.streamUrl,
      duration: pt.duration,
      playCount: pt.playCount,
      isLiked: pt.isLiked,
      coverImage: pt.coverUrl,
      createdAt: DateTime.now(), // Required but unknown
    )).toList();
  }
}
