import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/datasources/vibes_genre_mock_datasource.dart';
import 'package:rythmify/features/search/data/datasources/vibes_genre_remote_datasource.dart';

void main() {
  group('GenreRemoteSourceImpl', () {
    late Dio dio;
    late String? requestedPath;
    late Map<String, dynamic> responseData;

    setUp(() {
      requestedPath = null;
      responseData = {'data': <String, dynamic>{}};
      dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responseData,
              ),
            );
          },
        ),
      );
    });

    test('fetches genre page content', () async {
      responseData = {
        'data': {
          'genre': {'id': 'rock', 'name': 'Rock'},
          'tracks': [],
          'playlists': [],
          'albums': [],
          'artists': [],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final content = await source.getGenreContent('rock');

      expect(requestedPath, '/genres/rock/page');
      expect(content.genreInfo.id, 'rock');
    });

    test('fetches genre trending tracks', () async {
      responseData = {
        'data': {
          'tracks': [_trackJson()],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final tracks = await source.getGenreTrendingTracks('rock');

      expect(requestedPath, '/home/trending-by-genre/rock');
      expect(tracks.single.title, 'Track One');
    });

    test('fetches genre all tracks', () async {
      responseData = {
        'data': {
          'tracks': [_trackJson()],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final tracks = await source.getGenreAllTracks('rock');

      expect(requestedPath, '/genres/rock/tracks');
      expect(tracks.single.id, 'track-1');
    });

    test('fetches genre playlists', () async {
      responseData = {
        'data': {
          'playlists': [_playlistJson()],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final playlists = await source.getGenrePlaylists('rock');

      expect(requestedPath, '/genres/rock/playlists');
      expect(playlists.single.name, 'Playlist One');
    });

    test('fetches genre albums', () async {
      responseData = {
        'data': {
          'albums': [_albumJson()],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final albums = await source.getGenreAlbums('rock');

      expect(requestedPath, '/genres/rock/albums');
      expect(albums.single.name, 'Album One');
    });

    test('fetches genre artists', () async {
      responseData = {
        'data': {
          'artists': [_artistJson()],
        },
      };
      final source = GenreRemoteSourceImpl(dio: dio);

      final artists = await source.getGenreArtists('rock');

      expect(requestedPath, '/genres/rock/artists');
      expect(artists.single.displayName, 'Artist One');
    });

    test('propagates DioException from failed request', () async {
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(requestOptions: options, message: 'Network error'),
          ),
        ),
      );
      final source = GenreRemoteSourceImpl(dio: dio);

      expect(
        () => source.getGenreContent('rock'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('GenreRemoteSourceMock', () {
    late GenreRemoteSourceMock source;

    setUp(() {
      source = GenreRemoteSourceMock();
    });

    test('returns complete mock genre content', () async {
      final content = await source.getGenreContent('electronic');

      expect(content.genreInfo.id, 'electronic');
      expect(content.introducing.playlist.name, 'Best of the Genre');
      expect(content.tracks, hasLength(6));
      expect(content.playlists, hasLength(4));
      expect(content.albums, hasLength(4));
      expect(content.artists, hasLength(4));
    });

    test('returns mock lists for every endpoint', () async {
      expect(await source.getGenreTrendingTracks('pop'), hasLength(10));
      expect(await source.getGenreAllTracks('pop'), hasLength(20));
      expect(await source.getGenrePlaylists('pop'), hasLength(4));
      expect(await source.getGenreAlbums('pop'), hasLength(4));
      expect(await source.getGenreArtists('pop'), hasLength(4));
    });
  });
}

Map<String, dynamic> _trackJson() => {
  'id': 'track-1',
  'user_id': 'user-1',
  'title': 'Track One',
  'artist': 'Artist One',
  'audio_url': 'audio.mp3',
  'duration': 180,
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _playlistJson() => {
  'id': 'playlist-1',
  'name': 'Playlist One',
  'cover_image': 'cover.jpg',
  'owner_id': 'owner-1',
  'owner_name': 'Owner One',
  'track_count': 10,
  'like_count': 20,
  'source': 'tagged',
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _albumJson() => {
  'id': 'album-1',
  'name': 'Album One',
  'cover_image': 'cover.jpg',
  'owner_id': 'owner-1',
  'owner_name': 'Artist One',
  'track_count': 8,
  'like_count': 16,
  'release_date': '2026-01-01',
};

Map<String, dynamic> _artistJson() => {
  'id': 'artist-1',
  'display_name': 'Artist One',
  'username': 'artistone',
  'profile_picture': 'avatar.jpg',
  'is_verified': true,
  'follower_count': 100,
  'track_count_in_genre': 7,
};
