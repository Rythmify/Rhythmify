import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rythmify/features/feed/data/datasources/home_mock_datasource.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';
import 'package:rythmify/features/feed/domain/entities/mixed_for_you_item.dart';
import 'package:rythmify/features/feed/domain/entities/discover_station.dart';
import 'package:rythmify/core/domain/entities/track.dart';

// Minimal mock JSONs — adjust fields to match your actual models
const mockHomeJson = '''
{
  "data": {
    "hot_for_you": {
      "title": "Hot For You",
      "tracks": [
        {
          "id": "1",
          "title": "Test Track",
          "artist": "Test Artist",
          "duration": 200,
          "cover_url": "https://example.com/cover.jpg",
          "audio_url": "https://example.com/audio.mp3"
        }
      ]
    },
    "more_of_what_you_like": {
      "tracks": [
        {
          "id": "2",
          "title": "Another Track",
          "artist": "Another Artist",
          "duration": 180,
          "cover_url": "https://example.com/cover2.jpg",
          "audio_url": "https://example.com/audio2.mp3"
        }
      ]
    },
    "mixed_for_you": [
      {
        "id": "mix1",
        "title": "Mix 1",
        "cover_url": "https://example.com/mix.jpg"
      }
    ],
    "discover_with_stations": [
      {
        "id": "station1",
        "name": "Station 1",
        "cover_url": "https://example.com/station.jpg"
      }
    ]
  }
}
''';

const mockGenreJson = '''
{
  "data": {
    "genre_rock": {
      "genre_id": "genre_rock",
      "genre_name": "Rock",
      "tracks": [
        {
          "id": "3",
          "title": "Rock Track",
          "artist": "Rock Artist",
          "duration": 240,
          "cover_url": "https://example.com/rock.jpg",
          "audio_url": "https://example.com/rock.mp3"
        }
      ]
    }
  }
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset the cache between tests since it's a global variable
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  // Helper to register mock assets
  void mockAssets(String homeJson, String genreJson) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key.contains('mock_home.json')) {
            return ByteData.sublistView(utf8.encode(homeJson));
          }
          if (key.contains('mock_trending_genres.json')) {
            return ByteData.sublistView(utf8.encode(genreJson));
          }
          return null;
        });
  }

  group('HomeMockDatasource', () {
    late HomeMockDatasource datasource;

    setUp(() {
      datasource = HomeMockDatasource();
      mockAssets(mockHomeJson, mockGenreJson);
    });

    group('getHomeData', () {
      test('returns HomeData from mock JSON', () async {
        final result = await datasource.getHomeData();
        expect(result, isA<HomeData>());
      });
    });

    group('getTrendingByGenre', () {
      test('returns GenreTabTracks for a valid genreId', () async {
        final result = await datasource.getTrendingByGenre('genre_rock');
        expect(result, isA<GenreTabTracks>());
        expect(result.genreId, 'genre_rock');
        expect(result.genreName, 'Rock');
        expect(result.tracks, isNotEmpty);
      });

      test('returns empty GenreTabTracks for unknown genreId', () async {
        final result = await datasource.getTrendingByGenre(
          'non_existent_genre',
        );
        expect(result.genreId, 'non_existent_genre');
        expect(result.genreName, '');
        expect(result.tracks, isEmpty);
      });
    });

    group('getHotForYou', () {
      test('returns HotForYou from mock JSON', () async {
        final result = await datasource.getHotForYou();
        expect(result, isA<HotForYou>());
      });
    });

    group('getMoreOfWhatYouLike', () {
      test('returns list of Tracks', () async {
        final result = await datasource.getMoreOfWhatYouLike();
        expect(result, isA<List<Track>>());
        expect(result, isNotEmpty);
      });
    });

    group('getMixedForYou', () {
      test('returns list of MixedForYouItem', () async {
        final result = await datasource.getMixedForYou();
        expect(result, isA<List<MixedForYouItem>>());
        expect(result, isNotEmpty);
      });
    });

    group('getDiscoverStations', () {
      test('returns list of DiscoverStation', () async {
        final result = await datasource.getDiscoverStations();
        expect(result, isA<List<DiscoverStation>>());
        expect(result, isNotEmpty);
      });
    });

    group('caching', () {
      test('getHomeData uses cached result on second call', () async {
        final result1 = await datasource.getHomeData();
        final result2 = await datasource.getHomeData();
        // Both calls should return equivalent data
        expect(result1, isNotNull);
        expect(result2, isNotNull);
      });
    });
  });
}
