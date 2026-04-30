import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/search/data/datasources/vibes_genre_remote_datasource.dart';
import 'package:rythmify/features/search/data/repositories/vibes_genre_repository_impl.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_album.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_artists.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_info.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_playlist.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_playlist.dart';

class MockGenreRemoteSource extends Mock implements GenreRemoteSource {}

void main() {
  group('GenreRepositoryImpl', () {
    late MockGenreRemoteSource remoteSource;
    late GenreRepositoryImpl repository;

    setUp(() {
      remoteSource = MockGenreRemoteSource();
      repository = GenreRepositoryImpl(remoteSource: remoteSource);
    });

    test('delegates getGenreContent', () async {
      final content = _content();
      when(
        () => remoteSource.getGenreContent(any()),
      ).thenAnswer((_) async => content);

      final result = await repository.getGenreContent('rock');

      expect(result, content);
      verify(() => remoteSource.getGenreContent('rock')).called(1);
    });

    test('delegates getGenreTrendingTracks', () async {
      final tracks = [_track()];
      when(
        () => remoteSource.getGenreTrendingTracks(any()),
      ).thenAnswer((_) async => tracks);

      final result = await repository.getGenreTrendingTracks('rock');

      expect(result, tracks);
      verify(() => remoteSource.getGenreTrendingTracks('rock')).called(1);
    });

    test('delegates getGenrePlaylists', () async {
      final playlists = [_playlist()];
      when(
        () => remoteSource.getGenrePlaylists(any()),
      ).thenAnswer((_) async => playlists);

      final result = await repository.getGenrePlaylists('rock');

      expect(result, playlists);
      verify(() => remoteSource.getGenrePlaylists('rock')).called(1);
    });

    test('delegates getGenreAlbums', () async {
      final albums = [_album()];
      when(
        () => remoteSource.getGenreAlbums(any()),
      ).thenAnswer((_) async => albums);

      final result = await repository.getGenreAlbums('rock');

      expect(result, albums);
      verify(() => remoteSource.getGenreAlbums('rock')).called(1);
    });

    test('delegates getGenreArtists', () async {
      final artists = [_artist()];
      when(
        () => remoteSource.getGenreArtists(any()),
      ).thenAnswer((_) async => artists);

      final result = await repository.getGenreArtists('rock');

      expect(result, artists);
      verify(() => remoteSource.getGenreArtists('rock')).called(1);
    });

    test('delegates getGenreAllTracks', () async {
      final tracks = [_track()];
      when(
        () => remoteSource.getGenreAllTracks(any()),
      ).thenAnswer((_) async => tracks);

      final result = await repository.getGenreAllTracks('rock');

      expect(result, tracks);
      verify(() => remoteSource.getGenreAllTracks('rock')).called(1);
    });

    test('propagates remote exceptions', () async {
      when(
        () => remoteSource.getGenreArtists(any()),
      ).thenThrow(Exception('boom'));

      expect(() => repository.getGenreArtists('rock'), throwsException);
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
