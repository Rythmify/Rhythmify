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

class HomeRemoteDatasource {
  final Dio _dio;

  HomeRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<HomeData> getHomeData() async {
    final response = await _dio.get('/home');
    dev.log(
      'stations keys: ${(response.data['data'] as Map<String, dynamic>)['discover_with_stations']}',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.fromJson(data);
  }

  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    final response = await _dio.get('/home/trending-by-genre/$genreId');
    debugPrint(
      'DEBUG: /home/trending-by-genre/$genreId response: ${response.data}',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.parseGenreTabTracks(data);
  }

  Future<HotForYou> getHotForYou() async {
    final response = await _dio.get('/home/hot-for-you');
    debugPrint('DEBUG: /home/hot-for-you response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return HomeDto.parseHotForYou(data);
  }

  Future<List<Track>> getMoreOfWhatYouLike() async {
    final response = await _dio.get('/home/more-of-what-you-like');
    debugPrint('DEBUG: /home/more-of-what-you-like response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }

  Future<List<MixedForYouItem>> getMixedForYou() async {
    final response = await _dio.get('/home/mixed-for-you');
    debugPrint('DEBUG: /home/mixed-for-you response: ${response.data}');
    return (response.data['data'] as List)
        .map((m) => HomeDto.parseMixedForYouItem(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoverStation>> getDiscoverStations() async {
    final response = await _dio.get('/home/discover-stations');

    return (response.data['data'] as List)
        .map((s) => HomeDto.parseDiscoverStation(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Track>> getMixTracks(String mixId) async {
    dev.log('getMixTracks called with mixId: $mixId');
    final response = await _dio.get('/home/mixes/$mixId');
    dev.log('getMixTracks response: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }

  Future<List<Track>> getRelatedTracks(String trackId) async {
    final response = await _dio.get('/tracks/$trackId/related');
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }
}
