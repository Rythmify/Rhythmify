import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/track.dart';

import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../models/home_dto.dart';
import 'dart:developer' as dev;

/// Remote datasource responsible for fetching all home screen data
/// from the Rythmify backend API.
///
/// Each method corresponds to a dedicated endpoint and returns a typed
/// domain entity or list, parsed via [HomeDto].
class HomeRemoteDatasource {
  final Dio _dio;

  /// Creates a [HomeRemoteDatasource] with the given [Dio] instance.
  HomeRemoteDatasource({required Dio dio}) : _dio = dio;

  /// Fetches the main home screen data from `GET /home`.
  ///
  /// Returns a [HomeData] entity containing all sections needed
  /// to populate the home screen on initial load.
  Future<HomeData> getHomeData() async {
    final response = await _dio.get('/home');
    debugPrint('DEBUG: /home response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.fromJson(data);
  }

  /// Fetches trending tracks for a specific genre tab from
  /// `GET /home/trending-by-genre/{genreId}`.
  ///
  /// [genreId] is the identifier of the genre whose trending
  /// tracks should be retrieved.
  ///
  /// Returns a [GenreTabTracks] entity containing the track list
  /// for that genre.
  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    final response = await _dio.get('/home/trending-by-genre/$genreId');
    debugPrint(
      'DEBUG: /home/trending-by-genre/$genreId response: ${response.data}',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.parseGenreTabTracks(data);
  }

  /// Fetches the "Hot For You" personalized section from
  /// `GET /home/hot-for-you`.
  ///
  /// Returns a [HotForYou] entity representing tracks and playlists
  /// curated for the current user based on their listening history.
  Future<HotForYou> getHotForYou() async {
    final response = await _dio.get('/home/hot-for-you');
    debugPrint('DEBUG: /home/hot-for-you response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.parseHotForYou(data);
  }

  /// Fetches the "More Of What You Like" track list from
  /// `GET /home/more-of-what-you-like`.
  ///
  /// Returns a list of [Track] entities recommended based on
  /// the user's recent listening activity.
  Future<List<Track>> getMoreOfWhatYouLike() async {
    final response = await _dio.get('/home/more-of-what-you-like');
    debugPrint('DEBUG: /home/more-of-what-you-like response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the "Mixed For You" section from `GET /home/mixed-for-you`.
  ///
  /// Returns a list of [MixedForYouItem] entities, each of which may
  /// represent either a track or a playlist mix curated for the user.
  Future<List<MixedForYouItem>> getMixedForYou() async {
    final response = await _dio.get('/home/mixed-for-you');
    debugPrint('DEBUG: /home/mixed-for-you response: ${response.data}');
    return (response.data['data'] as List)
        .map((m) => HomeDto.parseMixedForYouItem(m as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the list of discover stations from
  /// `GET /home/discover-stations`.
  ///
  /// Returns a list of [DiscoverStation] entities representing
  /// algorithmically generated radio-style stations.
  Future<List<DiscoverStation>> getDiscoverStations() async {
    final response = await _dio.get('/home/discover-stations');
    debugPrint('DEBUG: /home/discover-stations response: ${response.data}');
    return (response.data['data'] as List)
        .map((s) => HomeDto.parseDiscoverStation(s as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the tracks belonging to a specific mix from
  /// `GET /home/mixes/{mixId}`.
  ///
  /// [mixId] is the identifier of the mix whose tracks should
  /// be retrieved.
  ///
  /// Returns a list of [Track] entities contained in that mix.
  Future<List<Track>> getMixTracks(String mixId) async {
    dev.log('getMixTracks called with mixId: $mixId');
    final response = await _dio.get('/home/mixes/$mixId');
    dev.log('getMixTracks response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }

  /// Fetches tracks related to a specific track from
  /// `GET /tracks/{trackId}/related`.
  ///
  /// [trackId] is the identifier of the track to find
  /// related content for.
  ///
  /// Returns a list of [Track] entities that are sonically or
  /// contextually similar to the given track.
  Future<List<Track>> getRelatedTracks(String trackId) async {
    final response = await _dio.get('/tracks/$trackId/related');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }
}
