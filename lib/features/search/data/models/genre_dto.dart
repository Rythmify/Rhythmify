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
  // ── Shared track parser (mirrors HomeDto.parseTrack) ──────────────────────
  static Track parseTrack(Map<String, dynamic> json) {
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
      if (json['genre'] == null && json['genre_name'] != null)
        'genre': json['genre_name'],
    });
  }

  static GenreContent parseGenreContent(Map<String, dynamic> json) {
    return GenreContent(
      genreInfo: parseGenreInfo(json['genre'] as Map<String, dynamic>? ?? {}),

      // Check if 'introducing' exists, otherwise provide a "null-object" default
      introducing: json['introducing'] != null
          ? parseIntroducingSection(json['introducing'] as Map<String, dynamic>)
          : IntroducingSection(
              playlist: IntroducingPlaylist(
                playlistId: '',
                ownerUserId: '',
                name: '',
                description: '',
                createdAt: DateTime.now(),
                trackCount: 0,
                likeCount: 0,
                coverImage: '',
                isPublic: true,
                previewTrack: Track(
                  userId: '',
                  id: '',
                  title: '',
                  artist: '',
                  audioUrl: '',
                  coverImage: '',
                  duration: Duration(),
                  genre: '',
                  createdAt: DateTime.now(),
                ),
              ),
              tracksPreview: [],
            ),

      tracks: (json['tracks'] as List? ?? [])
          .map((t) => parseTrack(t as Map<String, dynamic>))
          .toList(),
      playlists: (json['playlists'] as List? ?? [])
          .map((p) => parsePlaylist(p as Map<String, dynamic>))
          .toList(),
      albums: (json['albums'] as List? ?? [])
          .map((a) => parseAlbum(a as Map<String, dynamic>))
          .toList(),
      artists: (json['artists'] as List? ?? [])
          .map((a) => parseArtist(a as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── GenreInfo ─────────────────────────────────────────────────────────────
  static GenreInfo parseGenreInfo(Map<String, dynamic> json) {
    return GenreInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      coverImage: json['cover_image'] as String? ?? '',
      trackCount: (json['track_count'] as num?)?.toInt() ?? 0,
      artistCount: (json['artist_count'] as num?)?.toInt() ?? 0,
      playlistCount: (json['playlist_count'] as num?)?.toInt() ?? 0,
      albumCount: (json['album_count'] as num?)?.toInt() ?? 0,
    );
  }

  // ── IntroducingSection ────────────────────────────────────────────────────
  static IntroducingSection parseIntroducingSection(Map<String, dynamic> json) {
    return IntroducingSection(
      playlist: IntroducingPlaylist(
        playlistId: json['id'] as String,
        ownerUserId: json['owner_id'] as String,
        name: json['name'] as String,
        description: '',
        isPublic: true,
        createdAt: DateTime.parse(json['created_at'] as String),
        trackCount: json['track_count'] as int? ?? 0,
        likeCount: json['like_count'] as int? ?? 0,
        coverImage: json['cover_image'] as String? ?? '',
        previewTrack: (json['tracks_preview'] as List?)?.isNotEmpty == true
            ? parseTrack(
                (json['tracks_preview'] as List).first as Map<String, dynamic>,
              )
            : _emptyTrack(),
      ),
      tracksPreview: (json['tracks_preview'] as List? ?? [])
          .map((t) => parseTrack(t as Map<String, dynamic>))
          .toList(),
    );
  }

  static Track _emptyTrack() => TrackDto.fromJson({
    'id': '',
    'title': '',
    'artist': '',
    'audio_url': '',
    'cover_image': '',
    'duration': 0,
    'genre': '',
    'created_at': '2026-01-01T00:00:00Z',
    'user_id': '',
  });

  static IntroducingPlaylist parseIntroducingPlaylist(
    Map<String, dynamic> json,
  ) {
    return IntroducingPlaylist(
      playlistId: json['playlist_id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      trackCount: (json['track_count'] as num).toInt(),
      likeCount: (json['like_count'] as num).toInt(),
      coverImage: json['cover_image'] as String? ?? '',
      previewTrack: parseTrack(json['preview_track'] as Map<String, dynamic>),
    );
  }

  // ── GenrePlaylist ─────────────────────────────────────────────────────────
  static GenrePlaylist parsePlaylist(Map<String, dynamic> json) {
    return GenrePlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String,
      trackCount: (json['track_count'] as num).toInt(),
      likeCount: (json['like_count'] as num).toInt(),
      source: json['source'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ── GenreAlbum ────────────────────────────────────────────────────────────
  static GenreAlbum parseAlbum(Map<String, dynamic> json) {
    return GenreAlbum(
      id: json['id'] as String,
      name: json['name'] as String,
      coverImage: json['cover_image'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String,
      trackCount: (json['track_count'] as num).toInt(),
      likeCount: (json['like_count'] as num).toInt(),
      releaseDate: json['release_date'] as String? ?? '',
    );
  }

  // ── GenreArtist ───────────────────────────────────────────────────────────
  static GenreArtist parseArtist(Map<String, dynamic> json) {
    return GenreArtist(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      followerCount: (json['follower_count'] as num).toInt(),
      trackCountInGenre: (json['track_count_in_genre'] as num).toInt(),
    );
  }

  // ── Paginated list parsers ─────────────────────────────────────────────────
  static List<GenrePlaylist> parsePlaylistList(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['playlists'] as List)
        .map((p) => parsePlaylist(p as Map<String, dynamic>))
        .toList();
  }

  static List<GenreAlbum> parseAlbumList(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['albums'] as List)
        .map((a) => parseAlbum(a as Map<String, dynamic>))
        .toList();
  }

  static List<GenreArtist> parseArtistList(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['artists'] as List)
        .map((a) => parseArtist(a as Map<String, dynamic>))
        .toList();
  }

  static List<Track> parseTrackList(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => parseTrack(t as Map<String, dynamic>))
        .toList();
  }
}
