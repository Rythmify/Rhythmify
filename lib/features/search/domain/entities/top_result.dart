import '../../../../core/domain/entities/track.dart';
import '../../../profile/domain/entities/profile_entity.dart';

/// A sealed union representing the possible types of a top search result.
///
/// Subtypes cover the four searchable content kinds: track, user,
/// playlist, and album. Use exhaustive pattern matching to handle each case.
sealed class TopResult {}

/// A top search result that resolved to a [Track].
class TopResultTrack extends TopResult {
  final Track track;
  TopResultTrack(this.track);
}

/// A top search result that resolved to a [ProfileEntity].
class TopResultUser extends TopResult {
  final ProfileEntity profile;
  TopResultUser(this.profile);
}

/// A top search result that resolved to a playlist, represented as a
/// raw map of string fields until a dedicated playlist entity is available.
class TopResultPlaylist extends TopResult {
  final Map<String, String> playlist;
  TopResultPlaylist(this.playlist);
}

/// A top search result that resolved to an album, represented as a
/// raw map of string fields until a dedicated album entity is available.
class TopResultAlbum extends TopResult {
  final Map<String, String> album;
  TopResultAlbum(this.album);
}
