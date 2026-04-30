import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_album.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_artists.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_info.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_playlist.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_playlist.dart';
import 'package:rythmify/features/search/domain/repositories/vibes_genre_repository.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_albums.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_all_tracks.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_artists.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_playlists.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes_genre_trending.dart';

class MockGenreRepository extends Mock implements GenreRepository {}

void main() {
  group('genre usecases', () {
    late MockGenreRepository repository;

    setUp(() {
      repository = MockGenreRepository();
    });

    test('GetGenreContent delegates to repository', () async {
      final content = _content();
      when(
        () => repository.getGenreContent(any()),
      ).thenAnswer((_) async => content);

      final result = await GetGenreContent(repository)('rock');

      expect(result, content);
      verify(() => repository.getGenreContent('rock')).called(1);
    });

    test('GetGenreTracks delegates to trending repository method', () async {
      final tracks = [_track()];
      when(
        () => repository.getGenreTrendingTracks(any()),
      ).thenAnswer((_) async => tracks);

      final result = await GetGenreTracks(repository)('rock');

      expect(result, tracks);
      verify(() => repository.getGenreTrendingTracks('rock')).called(1);
    });

    test('GetGenreAllTracks delegates to repository', () async {
      final tracks = [_track()];
      when(
        () => repository.getGenreAllTracks(any()),
      ).thenAnswer((_) async => tracks);

      final result = await GetGenreAllTracks(repository)('rock');

      expect(result, tracks);
      verify(() => repository.getGenreAllTracks('rock')).called(1);
    });

    test('GetGenrePlaylists delegates to repository', () async {
      final playlists = [_playlist()];
      when(
        () => repository.getGenrePlaylists(any()),
      ).thenAnswer((_) async => playlists);

      final result = await GetGenrePlaylists(repository)('rock');

      expect(result, playlists);
      verify(() => repository.getGenrePlaylists('rock')).called(1);
    });

    test('GetGenreAlbums delegates to repository', () async {
      final albums = [_album()];
      when(
        () => repository.getGenreAlbums(any()),
      ).thenAnswer((_) async => albums);

      final result = await GetGenreAlbums(repository)('rock');

      expect(result, albums);
      verify(() => repository.getGenreAlbums('rock')).called(1);
    });

    test('GetGenreArtists delegates to repository', () async {
      final artists = [_artist()];
      when(
        () => repository.getGenreArtists(any()),
      ).thenAnswer((_) async => artists);

      final result = await GetGenreArtists(repository)('rock');

      expect(result, artists);
      verify(() => repository.getGenreArtists('rock')).called(1);
    });

    test('usecases propagate repository exceptions', () async {
      when(() => repository.getGenreAlbums(any())).thenThrow(Exception('boom'));

      expect(() => GetGenreAlbums(repository)('rock'), throwsException);
    });
  });
}

Track _track() => Track(
  id: 'track-1',
  userId: 'user-1',
  title: 'Track One',
  artist: 'Artist One',
  audioUrl: 'audio.mp3',
  duration: const Duration(seconds: 180),
  createdAt: DateTime(2026, 1, 1),
);

GenrePlaylist _playlist() => GenrePlaylist(
  id: 'playlist-1',
  name: 'Playlist One',
  coverImage: 'cover.jpg',
  ownerId: 'owner-1',
  ownerName: 'Owner One',
  trackCount: 10,
  likeCount: 20,
  source: 'tagged',
  createdAt: DateTime(2026, 1, 1),
);

GenreAlbum _album() => const GenreAlbum(
  id: 'album-1',
  name: 'Album One',
  coverImage: 'cover.jpg',
  ownerId: 'owner-1',
  ownerName: 'Artist One',
  trackCount: 8,
  likeCount: 16,
  releaseDate: '2026-01-01',
);

GenreArtist _artist() => const GenreArtist(
  id: 'artist-1',
  displayName: 'Artist One',
  username: 'artistone',
  profilePicture: 'avatar.jpg',
  isVerified: true,
  followerCount: 100,
  trackCountInGenre: 7,
);

GenreContent _content() => GenreContent(
  genreInfo: const GenreInfo(
    id: 'rock',
    name: 'Rock',
    coverImage: 'cover.jpg',
    trackCount: 1,
    artistCount: 1,
    playlistCount: 1,
    albumCount: 1,
  ),
  introducing: IntroducingSection(
    playlist: IntroducingPlaylist(
      playlistId: 'intro-1',
      ownerUserId: 'owner-1',
      name: 'Intro',
      description: '',
      isPublic: true,
      createdAt: DateTime(2026, 1, 1),
      trackCount: 1,
      likeCount: 1,
      coverImage: 'cover.jpg',
      previewTrack: _track(),
    ),
    tracksPreview: [_track()],
  ),
  playlists: [_playlist()],
  albums: [_album()],
  artists: [_artist()],
  tracks: [_track()],
);
