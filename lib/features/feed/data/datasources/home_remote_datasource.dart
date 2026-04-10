import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../models/home_dto.dart';

class HomeRemoteDatasource {
  final http.Client _client;
  final String _baseUrl;

  HomeRemoteDatasource({required http.Client client, required String baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  Future<HomeData> getHomeData() async {
    final response = await _client.get(Uri.parse('$_baseUrl/home'));
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return HomeDto.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/home/trending-by-genre/$genreId'),
    );
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return HomeDto.parseGenreTabTracks(json['data'] as Map<String, dynamic>);
  }

  Future<HotForYou> getHotForYou() async {
    final response = await _client.get(Uri.parse('$_baseUrl/home/hot-for-you'));
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return HomeDto.parseHotForYou(json['data'] as Map<String, dynamic>);
  }

  Future<List<Track>> getMoreOfWhatYouLike() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/home/more-of-what-you-like'),
    );
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    return (data['tracks'] as List)
        .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
        .toList();
  }

  Future<List<MixedForYouItem>> getMixedForYou() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/home/mixed-for-you'),
    );
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['data'] as List)
        .map((m) => HomeDto.parseMixedForYouItem(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoverStation>> getDiscoverStations() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/home/discover-stations'),
    );
    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['data'] as List)
        .map((s) => HomeDto.parseDiscoverStation(s as Map<String, dynamic>))
        .toList();
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
