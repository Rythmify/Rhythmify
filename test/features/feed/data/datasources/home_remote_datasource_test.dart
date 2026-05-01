import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/feed/data/datasources/home_remote_datasource.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';

// ============ Mock Classes ============
class MockDio extends Mock implements Dio {}

// ============ Test Fixtures ============
final tHomeResponseJson = {
  'data': {
    'hot_for_you': {
      'track': {
        'id': 'track-1',
        'title': 'Hot Track',
        'duration': 180,
        'play_count': 10000,
        'like_count': 1000,
        'cover_image': 'https://example.com/cover.jpg',
        'audio_url': 'https://example.com/audio.mp3',
      },
      'reason': 'Trending in your region',
      'valid_until': '2024-12-31T23:59:59Z',
    },
    'trending_by_genre': {
      'genres': [
        {
          'genre_id': 'electronic',
          'genre_name': 'Electronic',
        },
      ],
      'initial_tab': {
        'genre_id': 'electronic',
        'genre_name': 'Electronic',
        'tracks': [
          {
            'id': 'track-1',
            'title': 'Track 1',
            'duration': 180,
            'play_count': 5000,
            'like_count': 500,
            'audio_url': 'https://example.com/audio1.mp3',
          },
        ],
      },
    },
    'more_of_what_you_like': {
      'tracks': [
        {
          'id': 'track-1',
          'title': 'Like Track 1',
          'duration': 180,
          'play_count': 5000,
          'like_count': 500,
          'audio_url': 'https://example.com/audio1.mp3',
        },
      ],
    },
    'mixed_for_you': [
      {
        'id': 'mix-1',
        'label': 'Electronic Mix',
        'flavor': 'upbeat',
        'genre_name': 'Electronic',
        'cover_image': 'https://example.com/mix.jpg',
        'track_count': 20,
        'generated_at': '2024-01-01T00:00:00Z',
        'preview_track': {
          'id': 'track-1',
          'title': 'Preview',
          'duration': 180,
          'play_count': 5000,
          'like_count': 500,
          'audio_url': 'https://example.com/audio.mp3',
        },
      },
    ],
    'discover_with_stations': [
      {
        'id': 'station-1',
        'name': 'Test Station',
        'artist_id': 'artist-1',
        'artist_name': 'Test Artist',
        'cover_image': 'https://example.com/station.jpg',
        'track_count': 50,
        'follower_count': 1000,
      },
    ],
  },
};

final tGenreResponseJson = {
  'data': {
    'genre_id': 'electronic',
    'genre_name': 'Electronic',
    'tracks': [
      {
        'id': 'track-1',
        'title': 'Electronic Track',
        'duration': 200,
        'play_count': 8000,
        'like_count': 800,
        'audio_url': 'https://example.com/audio.mp3',
      },
    ],
  },
};

void main() {
  late HomeRemoteDatasource datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = HomeRemoteDatasource(dio: mockDio);
  });

  group('HomeRemoteDatasource', () {
    group('getHomeData', () {
      test('should return HomeData when call succeeds', () async {
        // Arrange
        when(() => mockDio.get('/home')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tHomeResponseJson['data']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getHomeData();

        // Assert
        expect(result, isA<HomeData>());
        expect(result.hotForYou, isA<HotForYou>());
        expect(result.trendingByGenre.genres.isNotEmpty, true);
        expect(result.moreOfWhatYouLike.isNotEmpty, true);
        expect(result.mixedForYou.isNotEmpty, true);
        expect(result.discoverWithStations.isNotEmpty, true);
        verify(() => mockDio.get('/home')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/home')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(() => datasource.getHomeData(), throwsA(isA<DioException>()));
      });
    });

    group('getTrendingByGenre', () {
      test('should return GenreTabTracks for given genre ID', () async {
        // Arrange
        when(() => mockDio.get('/home/trending-by-genre/electronic'))
            .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tGenreResponseJson['data']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getTrendingByGenre('electronic');

        // Assert
        expect(result, isA<GenreTabTracks>());
        expect(result.genreId, 'electronic');
        expect(result.genreName, 'Electronic');
        expect(result.tracks.isNotEmpty, true);
        verify(
          () => mockDio.get('/home/trending-by-genre/electronic'),
        ).called(1);
      });

      test('should call correct endpoint with genre ID', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tGenreResponseJson['data']},
            statusCode: 200,
          ),
        );

        // Act
        await datasource.getTrendingByGenre('pop');

        // Assert
        verify(() => mockDio.get('/home/trending-by-genre/pop')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getTrendingByGenre('electronic'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getHotForYou', () {
      test('should return HotForYou when call succeeds', () async {
        // Arrange
        when(() => mockDio.get('/home/hot-for-you')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tHomeResponseJson['data']!['hot_for_you']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getHotForYou();

        // Assert
        expect(result, isA<HotForYou>());
        expect(result.reason, 'Trending in your region');
        verify(() => mockDio.get('/home/hot-for-you')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/home/hot-for-you')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getHotForYou(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getMoreOfWhatYouLike', () {
      test('should return list of tracks when call succeeds', () async {
        // Arrange
        when(() => mockDio.get('/home/more-of-what-you-like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tHomeResponseJson['data']!['more_of_what_you_like']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getMoreOfWhatYouLike();

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockDio.get('/home/more-of-what-you-like')).called(1);
      });

      test('should return empty list when no tracks available', () async {
        // Arrange
        final emptyResponse = {
          'data': {
            'tracks': [],
          },
        };
        when(() => mockDio.get('/home/more-of-what-you-like')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: emptyResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getMoreOfWhatYouLike();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/home/more-of-what-you-like')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getMoreOfWhatYouLike(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getMixedForYou', () {
      test('should return list of mixed for you items when call succeeds',
          () async {
        // Arrange
        when(() => mockDio.get('/home/mixed-for-you')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tHomeResponseJson['data']!['mixed_for_you']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getMixedForYou();

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockDio.get('/home/mixed-for-you')).called(1);
      });

      test('should return empty list when no items available', () async {
        // Arrange
        when(() => mockDio.get('/home/mixed-for-you')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getMixedForYou();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/home/mixed-for-you')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getMixedForYou(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getDiscoverStations', () {
      test('should return list of discover stations when call succeeds',
          () async {
        // Arrange
        when(() => mockDio.get('/home/discover-stations')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': tHomeResponseJson['data']!['discover_with_stations']},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getDiscoverStations();

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockDio.get('/home/discover-stations')).called(1);
      });

      test('should return empty list when no stations available', () async {
        // Arrange
        when(() => mockDio.get('/home/discover-stations')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getDiscoverStations();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/home/discover-stations')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getDiscoverStations(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getMixTracks', () {
      test('should return list of tracks for mix ID when call succeeds',
          () async {
        // Arrange
        final mixResponse = {
          'data': {
            'tracks': [
              {
                'id': 'track-1',
                'title': 'Mix Track',
                'duration': 180,
                'play_count': 5000,
                'like_count': 500,
                'audio_url': 'https://example.com/audio.mp3',
              },
            ],
          },
        };
        when(() => mockDio.get('/home/mixes/mix-1')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: mixResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getMixTracks('mix-1');

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockDio.get('/home/mixes/mix-1')).called(1);
      });

      test('should call correct endpoint with mix ID', () async {
        // Arrange
        final mixResponse = {
          'data': {'tracks': []},
        };
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: mixResponse,
            statusCode: 200,
          ),
        );

        // Act
        await datasource.getMixTracks('specific-mix-id');

        // Assert
        verify(() => mockDio.get('/home/mixes/specific-mix-id')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getMixTracks('mix-1'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getRelatedTracks', () {
      test('should return list of related tracks for track ID when call succeeds',
          () async {
        // Arrange
        final relatedResponse = {
          'data': {
            'tracks': [
              {
                'id': 'track-2',
                'title': 'Related Track',
                'duration': 180,
                'play_count': 3000,
                'like_count': 300,
                'audio_url': 'https://example.com/audio.mp3',
              },
            ],
          },
        };
        when(() => mockDio.get('/tracks/track-1/related')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: relatedResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await datasource.getRelatedTracks('track-1');

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockDio.get('/tracks/track-1/related')).called(1);
      });

      test('should call correct endpoint with track ID', () async {
        // Arrange
        final relatedResponse = {
          'data': {'tracks': []},
        };
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: relatedResponse,
            statusCode: 200,
          ),
        );

        // Act
        await datasource.getRelatedTracks('specific-track-id');

        // Assert
        verify(() => mockDio.get('/tracks/specific-track-id/related'))
            .called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => datasource.getRelatedTracks('track-1'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
