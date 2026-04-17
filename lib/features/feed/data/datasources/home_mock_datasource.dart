import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../models/home_dto.dart';

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

class HomeMockDatasource {
  Future<HomeData> getHomeData() async {
    final json = await _loadMockData();
    return HomeDto.fromJson(json['data']);
  }

  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    final json = await _loadGenreMock();
    final data = json['data'] as Map<String, dynamic>;
    final genreData = data[genreId] as Map<String, dynamic>?;
    if (genreData == null) {
      return GenreTabTracks(genreId: genreId, genreName: '', tracks: []);
    }
    return HomeDto.parseGenreTabTracks(genreData);
  }

  Future<HotForYou> getHotForYou() async {
    final json = await _loadMockData();
    return HomeDto.parseHotForYou(json['data']['hot_for_you']);
  }

  Future<List<Track>> getMoreOfWhatYouLike() async {
    final json = await _loadMockData();
    final tracks = json['data']['more_of_what_you_like']['tracks'] as List;
    return tracks.map((t) => HomeDto.parseTrack(t)).toList();
  }

  Future<List<MixedForYouItem>> getMixedForYou() async {
    final json = await _loadMockData();
    final list = json['data']['mixed_for_you'] as List;
    return list.map((m) => HomeDto.parseMixedForYouItem(m)).toList();
  }

  Future<List<DiscoverStation>> getDiscoverStations() async {
    final json = await _loadMockData();
    final list = json['data']['discover_with_stations'] as List;
    return list.map((s) => HomeDto.parseDiscoverStation(s)).toList();
  }
}
