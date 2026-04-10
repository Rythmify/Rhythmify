import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_info.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import '../../domain/entities/vibes_genre_introducing_section.dart';
import '../../domain/entities/vibes_genre_introducing_playlist.dart';

class GenreDto {
  static Track _parseTrack(Map<String, dynamic> json) {
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
    });
  }

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

  static IntroducingSection _parseIntroducing(Map<String, dynamic> json) {
    return IntroducingSection(
      playlist: _parseIntroducingPlaylist(json['playlist']),
      tracksPreview: (json['tracks_preview'] as List)
          .map((t) => _parseTrack(t))
          .toList(),
    );
  }

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

  static List<GenrePlaylist> playlistsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['playlists'] as List)
        .map((p) => _parseGenrePlaylist(p))
        .toList();
  }

  static List<GenreAlbum> albumsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['albums'] as List).map((a) => _parseGenreAlbum(a)).toList();
  }

  static List<GenreArtist> artistsFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['artists'] as List).map((a) => _parseGenreArtist(a)).toList();
  }

  static List<Track> tracksFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['tracks'] as List).map((t) => _parseTrack(t)).toList();
  }
}
