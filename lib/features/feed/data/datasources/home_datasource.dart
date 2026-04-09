import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../models/home_dto.dart';
import 'package:flutter/services.dart';

Map<String, dynamic>? _cachedMock;

Future<Map<String, dynamic>> _loadMockData() async {
  if (_cachedMock != null) return _cachedMock!;

  final jsonString = await rootBundle.loadString('assets/mocks/mock_home.json');

  _cachedMock = jsonDecode(jsonString);
  return _cachedMock!;
}

Future<Map<String, dynamic>> _loadGenreMock() async {
  final jsonString = await rootBundle.loadString(
    'assets/mocks/mock_trending_genres.json',
  );

  return jsonDecode(jsonString);
}

class HomeDatasource {
  final http.Client _client;
  final String _baseUrl;

  HomeDatasource({required http.Client client, required String baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  // ====== Methods ======
  Future<HomeData> getHomeData() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/home'));
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return HomeDto.fromJson(json['data'] as Map<String, dynamic>);
    } catch (_) {
      final json = await _loadMockData();
      return HomeDto.fromJson(json['data']);
    }
  }

  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/home/trending-by-genre/$genreId'),
      );
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return HomeDto.parseGenreTabTracks(json['data'] as Map<String, dynamic>);
    } catch (_) {
      final json = await _loadGenreMock();
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Invalid genre mock structure');
      final genreData = data[genreId] as Map<String, dynamic>?;
      if (genreData == null) {
        return GenreTabTracks(genreId: genreId, genreName: '', tracks: []);
      }
      return HomeDto.parseGenreTabTracks(genreData);
    }
  }

  Future<HotForYou> getHotForYou() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/home/hot-for-you'),
      );
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return HomeDto.parseHotForYou(json['data'] as Map<String, dynamic>);
    } catch (_) {
      final json = await _loadMockData();
      return HomeDto.parseHotForYou(json['data']['hot_for_you']);
    }
  }

  Future<List<Track>> getMoreOfWhatYouLike() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/home/more-of-what-you-like'),
      );
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['data'] as List)
          .map((t) => HomeDto.parseTrack(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final json = await _loadMockData();
      final tracks = json['data']['more_of_what_you_like']['tracks'] as List;
      return tracks.map((t) => HomeDto.parseTrack(t)).toList();
    }
  }

  Future<List<MixedForYouItem>> getMixedForYou() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/home/mixed-for-you'),
      );
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['data'] as List)
          .map((m) => HomeDto.parseMixedForYouItem(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final json = await _loadMockData();

      final list = json['data']['mixed_for_you'] as List;

      return list.map((m) => HomeDto.parseMixedForYouItem(m)).toList();
    }
  }

  Future<List<DiscoverStation>> getDiscoverStations() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/home/discover-stations'),
      );
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['data'] as List)
          .map((s) => HomeDto.parseDiscoverStation(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final json = await _loadMockData();

      final list = json['data']['discover_with_stations'] as List;

      return list.map((s) => HomeDto.parseDiscoverStation(s)).toList();
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
