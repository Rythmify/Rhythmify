import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import 'package:dio/dio.dart';
import '../models/genre_dto.dart';
import 'dart:developer' as dev;

/// Contract for the genre/vibes remote data source.
/// Each method maps to a separate backend endpoint.
abstract class GenreRemoteSource {
  /// Returns the full content bundle for a genre page.
  Future<GenreContent> getGenreContent(String genreId);

  /// Returns trending tracks for the given [genreId].
  Future<List<Track>> getGenreTrendingTracks(String genreId);

  /// Returns playlists tagged under the given [genreId].
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId);

  /// Returns albums released under the given [genreId].
  Future<List<GenreAlbum>> getGenreAlbums(String genreId);

  /// Returns artists associated with the given [genreId].
  Future<List<GenreArtist>> getGenreArtists(String genreId);

  /// Returns all tracks for the given [genreId] (used by the See All page).
  Future<List<Track>> getGenreAllTracks(String genreId);
}

/// Real HTTP implementation of [GenreRemoteSource].
// ... keep your existing abstract class and Mock class exactly as-is ...

class GenreRemoteSourceImpl implements GenreRemoteSource {
  GenreRemoteSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<GenreContent> getGenreContent(String genreId) async {
    final response = await _dio.get('/genres/$genreId/page');
    final body = response.data as Map<String, dynamic>;

    final data = body['data'] as Map<String, dynamic>? ?? {};
    dev.log('FULL JSON RESPONSE: ${response.data}');
    return GenreDto.parseGenreContent(data);
  }

  @override
  Future<List<Track>> getGenreTrendingTracks(String genreId) async {
    final response = await _dio.get('/home/trending-by-genre/$genreId');
    dev.log('TRENDING RESPONSE: ${response.data}');
    return GenreDto.parseTrackList(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Track>> getGenreAllTracks(String genreId) async {
    final response = await _dio.get('/genres/$genreId/tracks');
    return GenreDto.parseTrackList(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId) async {
    final response = await _dio.get('/genres/$genreId/playlists');
    dev.log('PLAYLISTS RESPONSE: ${response.data}');
    return GenreDto.parsePlaylistList(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<GenreAlbum>> getGenreAlbums(String genreId) async {
    final response = await _dio.get('/genres/$genreId/albums');
    return GenreDto.parseAlbumList(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<GenreArtist>> getGenreArtists(String genreId) async {
    final response = await _dio.get('/genres/$genreId/artists');
    return GenreDto.parseArtistList(response.data as Map<String, dynamic>);
  }
}
