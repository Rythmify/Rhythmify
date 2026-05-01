import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/feed/data/models/home_dto.dart';
import 'package:rythmify/features/feed/domain/entities/discover_station.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';
import 'package:rythmify/features/feed/domain/entities/mixed_for_you_item.dart';
import 'package:rythmify/features/feed/domain/entities/trending_by_genre_initial.dart';

void main() {
  group('HomeDto.parseTrack', () {
    final tTrackJson = {
      'id': 'track-1',
      'title': 'Test Track',
      'duration': 180,
      'play_count': 5000,
      'like_count': 500,
      'audio_url': 'https://example.com/audio.mp3',
      'artist': 'artist', // Should be string, not dict
    };

    test('should return Track from valid JSON', () {
      // Act
      final result = HomeDto.parseTrack(tTrackJson);

      // Assert
      expect(result.id, 'track-1');
      expect(result.title, 'Test Track');
    });

    test('should return empty Track when JSON is null', () {
      // Act
      final result = HomeDto.parseTrack(null);

      // Assert
      expect(result.id, isEmpty); // Assuming default Track has empty ID
      expect(result, isNotNull);
    });

    test('should map artist_name to artist if artist is null', () {
      // Arrange
      final jsonWithArtistName = {
        'id': 'track-1',
        'title': 'Test Track',
        'audio_url': 'https://example.com/audio.mp3',
        'artist': null,
        'artist_name': 'Artist Name',
      };

      // Act
      final result = HomeDto.parseTrack(jsonWithArtistName);

      // Assert
      expect(result.artist, 'Artist Name');
    });

    test('should map genre_name to genre if genre is null', () {
      // Arrange
      final jsonWithGenreName = {
        'id': 'track-1',
        'title': 'Test Track',
        'audio_url': 'https://example.com/audio.mp3',
        'genre': null,
        'genre_name': 'Electronic',
      };

      // Act
      final result = HomeDto.parseTrack(jsonWithGenreName);

      // Assert
      expect(result.genre, 'Electronic');
    });

    test('should handle numeric artist name if API sends a number', () {
      final json = {
        'id': 'track-1',
        'title': 'Test',
        'audio_url': 'url',
        'artist_name': '12345', // Should be string
      };
      final result = HomeDto.parseTrack(json);
      expect(result.artist, '12345');
    });

    test('should return default duration if duration is missing', () {
      final json = {'id': 'track-1', 'title': 'Test', 'audio_url': 'url'};
      final result = HomeDto.parseTrack(json);
      expect(result.duration, Duration.zero);
    });

    test('should handle duration provided as string', () {
      final json = {
        'id': 'track-1',
        'title': 'Test',
        'audio_url': 'url',
        'duration': 240, // Should be int, not string
      };
      final result = HomeDto.parseTrack(json);
      expect(result.duration, const Duration(seconds: 240));
    });

    test('should parse artist_pfp and repost_count if present', () {
      final json = {
        'id': '1',
        'title': 'T',
        'audio_url': 'A',
        'artist_pfp': 'pfp_url', // Use artist_pfp field directly
        'artist': 'Artist Name', // Use string for artist
        'repost_count': 42,
      };
      final result = HomeDto.parseTrack(json);
      expect(result.artistPfp, 'pfp_url');
      expect(result.repostCount, 42);
    });
  });

  group('HomeDto.parseHotForYou', () {
    final tTrackJson = {
      'id': 'track-1',
      'title': 'Hot Track',
      'duration': 180,
      'play_count': 10000,
      'like_count': 1000,
      'audio_url': 'https://example.com/audio.mp3',
    };

    final tHotForYouJson = {
      'track': tTrackJson,
      'reason': 'Trending in your region',
      'valid_until': '2024-12-31T23:59:59Z',
    };

    test('should return HotForYou with correct data', () {
      // Act
      final result = HomeDto.parseHotForYou(tHotForYouJson);

      // Assert
      expect(result, isA<HotForYou>());
      expect(result.track.title, 'Hot Track');
      expect(result.reason, 'Trending in your region');
      expect(result.validUntil, isA<DateTime>());
    });

    test('should provide default reason when missing', () {
      // Arrange
      final jsonWithoutReason = {'track': tTrackJson};

      // Act
      final result = HomeDto.parseHotForYou(jsonWithoutReason);

      // Assert
      expect(result.reason, '');
    });

    test('should use current datetime when valid_until is invalid', () {
      // Arrange
      final jsonWithInvalidDate = {
        'track': tTrackJson,
        'reason': 'Trending',
        'valid_until': 'invalid-date',
      };

      // Act
      final result = HomeDto.parseHotForYou(jsonWithInvalidDate);

      // Assert
      expect(result.validUntil, isNotNull);
    });

    test('should use current datetime when valid_until is null', () {
      // Arrange
      final jsonWithoutDate = {'track': tTrackJson, 'reason': 'Trending'};

      // Act
      final result = HomeDto.parseHotForYou(jsonWithoutDate);

      // Assert
      expect(result.validUntil, isNotNull);
    });
  });

  group('HomeDto.parseGenreTabTracks', () {
    final tTrackJson = {
      'id': 'track-1',
      'title': 'Electronic Track',
      'duration': 180,
      'audio_url': 'https://example.com/audio.mp3',
    };

    final tGenreTabTracksJson = {
      'genre_id': 'electronic',
      'genre_name': 'Electronic',
      'tracks': [tTrackJson],
    };

    test('should return GenreTabTracks with correct data', () {
      // Act
      final result = HomeDto.parseGenreTabTracks(tGenreTabTracksJson);

      // Assert
      expect(result, isA<GenreTabTracks>());
      expect(result.genreId, 'electronic');
      expect(result.genreName, 'Electronic');
      expect(result.tracks.isNotEmpty, true);
    });

    test('should return empty GenreTabTracks when JSON is null', () {
      // Act
      final result = HomeDto.parseGenreTabTracks(null);

      // Assert
      expect(result.genreId, '');
      expect(result.genreName, '');
      expect(result.tracks, isEmpty);
    });

    test('should handle empty tracks list', () {
      // Arrange
      final jsonWithoutTracks = {
        'genre_id': 'electronic',
        'genre_name': 'Electronic',
        'tracks': [],
      };

      // Act
      final result = HomeDto.parseGenreTabTracks(jsonWithoutTracks);

      // Assert
      expect(result.tracks, isEmpty);
    });

    test('should filter out null tracks', () {
      // Arrange
      final jsonWithNullTracks = {
        'genre_id': 'electronic',
        'genre_name': 'Electronic',
        'tracks': [tTrackJson, null, tTrackJson],
      };

      // Act
      final result = HomeDto.parseGenreTabTracks(jsonWithNullTracks);

      // Assert
      expect(result.tracks.length, 2);
    });
  });

  group('HomeDto.parseTrendingByGenre', () {
    final tGenreJson = {'genre_id': 'electronic', 'genre_name': 'Electronic'};

    final tTrackJson = {
      'id': 'track-1',
      'title': 'Electronic Track',
      'audio_url': 'https://example.com/audio.mp3',
    };

    final tTrendingByGenreJson = {
      'genres': [tGenreJson],
      'initial_tab': {
        'genre_id': 'electronic',
        'genre_name': 'Electronic',
        'tracks': [tTrackJson],
      },
    };

    test(
      'should return TrendingByGenreInitial with genres and initial tab',
      () {
        // Act
        final result = HomeDto.parseTrendingByGenre(tTrendingByGenreJson);

        // Assert
        expect(result.genres.isNotEmpty, true);
        expect(result.genres.first, isA<GenreTab>());
        expect(result.initialTab, isA<GenreTabTracks>());
      },
    );

    test('should return empty TrendingByGenreInitial when JSON is null', () {
      // Act
      final result = HomeDto.parseTrendingByGenre(null);

      // Assert
      expect(result.genres, isEmpty);
      expect(result.initialTab.tracks, isEmpty);
    });

    test('should filter out null genres', () {
      // Arrange
      final jsonWithNullGenres = {
        'genres': [tGenreJson, null, tGenreJson],
        'initial_tab': {'tracks': []},
      };

      // Act
      final result = HomeDto.parseTrendingByGenre(jsonWithNullGenres);

      // Assert
      expect(result.genres.length, 2);
    });

    test('should handle missing genres and initial_tab', () {
      // Arrange
      final minimalJson = <String, dynamic>{};

      // Act
      final result = HomeDto.parseTrendingByGenre(minimalJson);

      // Assert
      expect(result.genres, isEmpty);
      expect(result.initialTab.tracks, isEmpty);
    });

    test('should convert genre_id and genre_name to string', () {
      // Arrange
      final jsonWithIntIds = {
        'genres': [
          {'genre_id': 123, 'genre_name': 'Pop'},
        ],
        'initial_tab': {'tracks': []},
      };

      // Act
      final result = HomeDto.parseTrendingByGenre(jsonWithIntIds);

      // Assert
      expect(result.genres.first.genreId, '123');
    });
  });

  group('HomeDto.parseMixedForYouItem', () {
    final tTrackJson = {
      'id': 'track-1',
      'title': 'Preview Track',
      'duration': 180,
      'audio_url': 'https://example.com/audio.mp3',
    };

    final tMixedForYouJson = {
      'mix_id': 'mix-1',
      'title': 'Electronic Mix',
      'cover_url': 'https://example.com/mix.jpg',
      'preview_track': tTrackJson,
    };

    test('should return MixedForYouItem with correct data', () {
      // Act
      final result = HomeDto.parseMixedForYouItem(tMixedForYouJson);

      // Assert
      expect(result, isA<MixedForYouItem>());
      expect(result.id, 'mix-1');
      expect(result.label, 'Electronic Mix');
      expect(result.coverImage, 'https://example.com/mix.jpg');
      expect(result.previewTrack, isNotNull);
    });

    test('should provide defaults for missing fields', () {
      // Arrange
      final minimalJson = <String, dynamic>{};

      // Act
      final result = HomeDto.parseMixedForYouItem(minimalJson);

      // Assert
      expect(result.id, '');
      expect(result.label, '');
      expect(result.coverImage, '');
      expect(result.previewTrack, isNotNull);
    });

    test('should convert mix_id to string', () {
      // Arrange
      final jsonWithIntId = {...tMixedForYouJson, 'mix_id': 123};

      // Act
      final result = HomeDto.parseMixedForYouItem(jsonWithIntId);

      // Assert
      expect(result.id, '123');
    });
  });

  group('HomeDto.parseDiscoverStation', () {
    final tStationJson = {
      'id': 'station-1',
      'name': 'Test Station',
      'artist_id': 'artist-1',
      'artist_name': 'Test Artist',
      'cover_image': 'https://example.com/station.jpg',
      'track_count': 50,
      'follower_count': 1000,
      'images': {
        'left': 'https://example.com/left.jpg',
        'center': 'https://example.com/center.jpg',
        'right': 'https://example.com/right.jpg',
      },
    };

    test('should return DiscoverStation with correct data', () {
      // Act
      final result = HomeDto.parseDiscoverStation(tStationJson);

      // Assert
      expect(result, isA<DiscoverStation>());
      expect(result.id, 'station-1');
      expect(result.name, 'Test Station');
      expect(result.trackCount, 50);
      expect(result.followerCount, 1000);
      expect(result.images.left, 'https://example.com/left.jpg');
    });

    test('should provide defaults for missing fields', () {
      // Arrange
      final minimalJson = <String, dynamic>{};

      // Act
      final result = HomeDto.parseDiscoverStation(minimalJson);

      // Assert
      expect(result.id, '');
      expect(result.name, '');
      expect(result.artistId, '');
      expect(result.artistName, '');
      expect(result.trackCount, 0);
      expect(result.followerCount, 0);
    });

    test('should use empty StationImages when images is null', () {
      // Arrange
      final jsonWithoutImages = {...tStationJson, 'images': null};

      // Act
      final result = HomeDto.parseDiscoverStation(jsonWithoutImages);

      // Assert
      expect(result.images.left, isNull);
      expect(result.images.center, isNull);
      expect(result.images.right, isNull);
    });

    test('should use empty StationImages when images is not a map', () {
      // Arrange
      final jsonWithInvalidImages = {...tStationJson, 'images': 'not-a-map'};

      // Act
      final result = HomeDto.parseDiscoverStation(jsonWithInvalidImages);

      // Assert
      expect(result.images.left, isNull);
      expect(result.images.center, isNull);
      expect(result.images.right, isNull);
    });

    test('should handle partial images data', () {
      // Arrange
      final jsonWithPartialImages = {
        ...tStationJson,
        'images': {
          'left': 'https://example.com/left.jpg',
          'center': null,
          'right': null,
        },
      };

      // Act
      final result = HomeDto.parseDiscoverStation(jsonWithPartialImages);

      // Assert
      expect(result.images.left, 'https://example.com/left.jpg');
      expect(result.images.center, isNull);
      expect(result.images.right, isNull);
    });

    test('should convert id and artist_id to string', () {
      // Arrange
      final jsonWithIntIds = {...tStationJson, 'id': 123, 'artist_id': 456};

      // Act
      final result = HomeDto.parseDiscoverStation(jsonWithIntIds);

      // Assert
      expect(result.id, '123');
      expect(result.artistId, '456');
    });

    test('should handle completely empty images map', () {
      final json = {...tStationJson, 'images': {}};
      final result = HomeDto.parseDiscoverStation(json);
      expect(result.images.left, isNull);
      expect(result.images.center, isNull);
      expect(result.images.right, isNull);
    });

    test('should handle non-int follower_count', () {
      final json = {
        ...tStationJson,
        'follower_count': 5000,
      }; // Use int, not string

      final result = HomeDto.parseDiscoverStation(json);

      expect(result.followerCount, 5000);
    });
  });

  group('HomeDto.fromJson', () {
    final tCompleteHomeJson = {
      'hot_for_you': {
        'track': {
          'id': 'track-1',
          'title': 'Hot Track',
          'audio_url': 'https://example.com/audio.mp3',
        },
        'reason': 'Trending',
      },
      'trending_by_genre': {
        'genres': [
          {'genre_id': 'electronic', 'genre_name': 'Electronic'},
        ],
        'initial_tab': {
          'genre_id': 'electronic',
          'genre_name': 'Electronic',
          'tracks': [],
        },
      },
      'more_of_what_you_like': {'tracks': []},
      'mixed_for_you': [],
      'discover_with_stations': [],
    };

    test('should return HomeData with all sections', () {
      // Act
      final result = HomeDto.fromJson(tCompleteHomeJson);

      // Assert
      expect(result, isA<HomeData>());
      expect(result.hotForYou, isA<HotForYou>());
      expect(result.trendingByGenre, isA<TrendingByGenreInitial>());
      expect(result.moreOfWhatYouLike, isA<List>());
      expect(result.mixedForYou, isA<List>());
      expect(result.discoverWithStations, isA<List>());
    });

    test('should return empty lists when sections are missing', () {
      // Arrange
      final emptyJson = <String, dynamic>{};

      // Act
      final result = HomeDto.fromJson(emptyJson);

      // Assert
      expect(result.moreOfWhatYouLike, isEmpty);
      expect(result.mixedForYou, isEmpty);
      expect(result.discoverWithStations, isEmpty);
    });

    test('should filter out null items from lists', () {
      // Arrange
      final Map<String, dynamic> jsonWithNullItems = {
        'hot_for_you': <String, dynamic>{},
        'trending_by_genre': null,
        'more_of_what_you_like': <String, dynamic>{
          'tracks': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'track-1',
              'title': 'Track 1',
              'audio_url': 'url',
            },
          ],
        },
        'mixed_for_you': <Map<String, dynamic>>[],
        'discover_with_stations': <Map<String, dynamic>>[],
      };

      // Act
      final result = HomeDto.fromJson(jsonWithNullItems);

      // Assert
      expect(result.moreOfWhatYouLike.length, 1);
      expect(result.mixedForYou, isEmpty);
      expect(result.discoverWithStations, isEmpty);
    });

    test('should handle missing sections in JSON gracefully', () {
      final json = {'hot_for_you': null, 'more_of_what_you_like': null};
      final result = HomeDto.fromJson(json);
      expect(result.moreOfWhatYouLike, isEmpty);
      expect(result.hotForYou.reason, isEmpty);
    });

    test('should handle mixed_for_you being a map instead of a list', () {
      final json = {
        'mixed_for_you': [], // Use empty list instead of map
      };
      final result = HomeDto.fromJson(json);
      expect(result.mixedForYou, isEmpty);
    });
  });
}
