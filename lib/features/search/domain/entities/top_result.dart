import '../../../../core/domain/entities/track.dart';
import '../../../profile/domain/entities/profile_entity.dart';

sealed class TopResult {}

class TopResultTrack extends TopResult {
  final Track track;
  TopResultTrack(this.track);
}

class TopResultUser extends TopResult {
  final ProfileEntity profile;
  TopResultUser(this.profile);
}

class TopResultPlaylist extends TopResult {
  final Map<String, String> playlist;
  TopResultPlaylist(this.playlist);
}

class TopResultAlbum extends TopResult {
  final Map<String, String> album;
  TopResultAlbum(this.album);
}
