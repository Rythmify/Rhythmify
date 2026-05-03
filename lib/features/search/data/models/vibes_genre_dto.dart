import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_info.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import '../../domain/entities/vibes_genre_introducing_section.dart';
import '../../domain/entities/vibes_genre_introducing_playlist.dart';

/// DTO responsible for deserializing all genre/vibes-related API responses
/// into their corresponding domain entities.
/// All methods are static — no instantiation needed.
class GenreDto {
  /// Parses a track JSON map into a [Track] entity via [TrackDto].
  /// Normalises the artist field: maps `artist_name` → `artist` if `artist` is absent.
  static Track _parseTrack(Map<String, dynamic> json) {
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
    });
  }

  /// Parses a full genre page response into a [GenreContent] bundle.
  /// Expects a top-level `data` key containing genre, introducing, playlists, albums, artists, and tracks.
  static GenreContent fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return GenreContent(
      genreInfo: _parseGenreInfo(data['genre']),
      introducing: _parseIntroducing(data['introducing']),
      playlists: (data['playlists'] as List)
          .map((p) => _parseGenrePlaylist(p))
          .toList(),
      albums: (data['albums'] as List).map((a) => _parseGenreAlbum(a)).toList(),
      artists: (data['artists'] as List)
          .map((a) => _parseGenreArtist(a))
          .toList(),
      tracks: (data['tracks'] as List).map((t) => _parseTrack(t)).toList(),
    );
  }

  /// Parses genre metadata (name, counts, cover image) into a [GenreInfo].
  static GenreInfo _parseGenreInfo(Map<String, dynamic> json) {
    return GenreInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      artistCount: json['artist_count'] as int? ?? 0,
      playlistCount: json['playlist_count'] as int? ?? 0,
      albumCount: json['album_count'] as int? ?? 0,
    );
  }

  /// Parses the "Introducing" section, which contains a featured playlist and track previews.
  static IntroducingSection _parseIntroducing(Map<String, dynamic> json) {
    return IntroducingSection(
      playlist: _parseIntroducingPlaylist(json['playlist']),
      tracksPreview: (json['tracks_preview'] as List)
          .map((t) => _parseTrack(t))
          .toList(),
    );
  }

  /// Parses the featured playlist inside the Introducing section, including its preview track.
  static IntroducingPlaylist _parseIntroducingPlaylist(
    Map<String, dynamic> json,
  ) {
    return IntroducingPlaylist(
      playlistId: json['playlist_id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      trackCount: json['track_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      coverImage: json['cover_image'] as String? ?? '',
      previewTrack: _parseTrack(json['preview_track']),
    );
  }

  /// Parses a single playlist entry on the genre page into a [GenrePlaylist].
  static GenrePlaylist _parseGenrePlaylist(Map<String, dynamic> json) {
    return GenrePlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      source: json['source'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Parses a single album entry on the genre page into a [GenreAlbum].
  static GenreAlbum _parseGenreAlbum(Map<String, dynamic> json) {
    return GenreAlbum(
      id: json['id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
    );
  }

  /// Parses a single artist entry on the genre page into a [GenreArtist].
  static GenreArtist _parseGenreArtist(Map<String, dynamic> json) {
    return GenreArtist(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      followerCount: json['follower_count'] as int? ?? 0,
      trackCountInGenre: json['track_count_in_genre'] as int? ?? 0,
    );
  }

  /// Parses a playlists-only endpoint response into a list of [GenrePlaylist].
  /// Used by the independent playlists tab provider.
  static List<GenrePlaylist> playlistsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['playlists'] as List)
        .map((p) => _parseGenrePlaylist(p))
        .toList();
  }

  /// Parses an albums-only endpoint response into a list of [GenreAlbum].
  /// Used by the independent albums tab provider.
  static List<GenreAlbum> albumsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['albums'] as List).map((a) => _parseGenreAlbum(a)).toList();
  }

  /// Parses an artists-only endpoint response into a list of [GenreArtist].
  /// Used by the independent artists tab provider.
  static List<GenreArtist> artistsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['artists'] as List).map((a) => _parseGenreArtist(a)).toList();
  }

  /// Parses a tracks-only endpoint response into a list of [Track].
  /// Used by the independent tracks/trending tab provider.
  static List<Track> tracksFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['tracks'] as List).map((t) => _parseTrack(t)).toList();
  }
}
