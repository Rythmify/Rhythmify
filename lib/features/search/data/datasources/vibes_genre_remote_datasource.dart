import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_info.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import '../../domain/entities/vibes_genre_introducing_section.dart';
import '../../domain/entities/vibes_genre_introducing_playlist.dart';

abstract class GenreRemoteSource {
  Future<GenreContent> getGenreContent(String genreId);
  Future<List<Track>> getGenreTrendingTracks(String genreId);
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId);
  Future<List<GenreAlbum>> getGenreAlbums(String genreId);
  Future<List<GenreArtist>> getGenreArtists(String genreId);
  Future<List<Track>> getGenreAllTracks(String genreId);
}

class GenreRemoteSourceMock implements GenreRemoteSource {
  Track get _mockTrack => Track(
    id: 'e5f6a7b8',
    userId: 'a1b2c3d4',
    title: 'Summer Vibes',
    artist: 'DJ Karim',
    audioUrl: '',
    coverImage: 'assets/images/vibes_hiphop.jpeg',
    duration: const Duration(seconds: 213),
    playCount: 4200,
    likeCount: 312,
    repostCount: 47,
    createdAt: DateTime(2026, 3, 1),
    genre: 'Electronic',
  );

  GenreInfo _mockGenreInfo(String genreId) => GenreInfo(
    id: genreId,
    name: genreId,
    coverImage: 'assets/images/vibes_hiphop.jpeg',
    trackCount: 340,
    artistCount: 50,
    playlistCount: 20,
    albumCount: 15,
  );

  IntroducingSection get _mockIntroducing => IntroducingSection(
    playlist: IntroducingPlaylist(
      playlistId: 'pl-intro-1',
      ownerUserId: 'u1',
      name: 'Best of the Genre',
      description: 'A curated intro playlist',
      isPublic: true,
      createdAt: DateTime(2026, 1, 1),
      trackCount: 20,
      likeCount: 500,
      coverImage: 'assets/images/vibes_hiphop.jpeg',
      previewTrack: _mockTrack,
    ),
    tracksPreview: List.generate(3, (_) => _mockTrack),
  );

  List<GenrePlaylist> _mockPlaylists(String genreId) => List.generate(
    4,
    (i) => GenrePlaylist(
      id: 'playlist-$genreId-$i',
      name: 'Playlist ${i + 1}',
      coverImage: 'assets/images/vibes_hiphop.jpeg',
      ownerId: 'u1',
      ownerName: 'Rythmify',
      trackCount: 20,
      likeCount: 100,
      source: 'tagged',
      createdAt: DateTime(2026, 1, i + 1),
    ),
  );

  List<GenreAlbum> _mockAlbums(String genreId) => List.generate(
    4,
    (i) => GenreAlbum(
      id: 'album-$genreId-$i',
      name: 'Album ${i + 1}',
      coverImage: 'assets/images/vibes_hiphop.jpeg',
      ownerId: 'u1',
      ownerName: 'Artist ${i + 1}',
      trackCount: 12,
      likeCount: 200,
      releaseDate: '2026-01-0${i + 1}',
    ),
  );

  List<GenreArtist> _mockArtists(String genreId) => List.generate(
    4,
    (i) => GenreArtist(
      id: 'artist-$genreId-$i',
      displayName: 'Artist ${i + 1}',
      username: 'artist${i + 1}',
      profilePicture: '',
      isVerified: i == 0,
      followerCount: 1000 * (i + 1),
      trackCountInGenre: 10 + i,
    ),
  );

  @override
  Future<GenreContent> getGenreContent(String genreId) async {
    return GenreContent(
      genreInfo: _mockGenreInfo(genreId),
      introducing: _mockIntroducing,
      playlists: _mockPlaylists(genreId),
      albums: _mockAlbums(genreId),
      artists: _mockArtists(genreId),
      tracks: List.generate(6, (_) => _mockTrack),
    );
  }

  @override
  Future<List<Track>> getGenreTrendingTracks(String genreId) async {
    return List.generate(10, (_) => _mockTrack);
  }

  @override
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId) async {
    return _mockPlaylists(genreId);
  }

  @override
  Future<List<GenreAlbum>> getGenreAlbums(String genreId) async {
    return _mockAlbums(genreId);
  }

  @override
  Future<List<GenreArtist>> getGenreArtists(String genreId) async {
    return _mockArtists(genreId);
  }

  @override
  Future<List<Track>> getGenreAllTracks(String genreId) async {
    return List.generate(20, (_) => _mockTrack);
  }
}
