import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/feed/data/datasources/home_mock_datasource.dart';
import 'package:rythmify/features/feed/data/datasources/home_remote_datasource.dart';
import 'package:rythmify/features/feed/data/repositories/home_repository_impl.dart';
import 'package:rythmify/features/feed/domain/entities/discover_station.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';
import 'package:rythmify/features/feed/domain/entities/mixed_for_you_item.dart';
import 'package:rythmify/features/feed/domain/entities/trending_by_genre_initial.dart';

// ============ Mock Classes ============
class MockHomeRemoteDatasource extends Mock implements HomeRemoteDatasource {}

class MockHomeMockDatasource extends Mock implements HomeMockDatasource {}

// ============ Test Fixtures ============
final tTrack = Track(
  id: 'track-1',
  userId: 'user-1',
  title: 'Test Track',
  artist: 'Test Artist',
  audioUrl: 'https://example.com/audio.mp3',
  duration: const Duration(seconds: 180),
  createdAt: DateTime(2024, 1, 1),
);

final tHomeData = HomeData(
  hotForYou: HotForYou(
    track: tTrack,
    reason: 'Trending',
    validUntil: DateTime(2024, 12, 31),
  ),
  trendingByGenre: TrendingByGenreInitial(
    genres: [],
    initialTab: GenreTabTracks(
      genreId: 'electronic',
      genreName: 'Electronic',
      tracks: [],
    ),
  ),
  moreOfWhatYouLike: [tTrack],
  mixedForYou: [],
  discoverWithStations: [],
);

final tGenreTabTracks = GenreTabTracks(
  genreId: 'electronic',
  genreName: 'Electronic',
  tracks: [tTrack],
);

final tHotForYou = HotForYou(
  track: tTrack,
  reason: 'Trending in your region',
  validUntil: DateTime(2024, 12, 31),
);

final tMixedForYouItem = MixedForYouItem(
  id: 'mix-1',
  label: 'Electronic Mix',
  flavor: 'upbeat',
  genreName: 'Electronic',
  coverImage: 'https://example.com/mix.jpg',
  trackCount: 20,
  generatedAt: DateTime(2024, 1, 1),
  previewTrack: tTrack,
);

final tDiscoverStation = DiscoverStation(
  id: 'station-1',
  name: 'Test Station',
  artistId: 'artist-1',
  artistName: 'Test Artist',
  coverImage: 'https://example.com/station.jpg',
  trackCount: 50,
  followerCount: 1000,
);

void main() {
  group('HomeRepositoryImpl.remote', () {
    late HomeRepositoryImpl repository;
    late MockHomeRemoteDatasource mockRemoteDatasource;

    setUp(() {
      mockRemoteDatasource = MockHomeRemoteDatasource();
      repository = HomeRepositoryImpl.remote(mockRemoteDatasource);
      registerFallbackValue(tTrack);
      registerFallbackValue(<Track>[]);
      registerFallbackValue(<MixedForYouItem>[]);
      registerFallbackValue(<DiscoverStation>[]);
    });

    group('getHomeData', () {
      test('should return HomeData from remote datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getHomeData(),
        ).thenAnswer((_) async => tHomeData);

        // Act
        final result = await repository.getHomeData();

        // Assert
        expect(result, tHomeData);
        verify(() => mockRemoteDatasource.getHomeData()).called(1);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getHomeData(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getHomeData(), throwsException);
      });
    });

    group('getTrendingByGenre', () {
      test('should return GenreTabTracks from remote datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getTrendingByGenre(any()),
        ).thenAnswer((_) async => tGenreTabTracks);

        // Act
        final result = await repository.getTrendingByGenre('electronic');

        // Assert
        expect(result, tGenreTabTracks);
        verify(
          () => mockRemoteDatasource.getTrendingByGenre('electronic'),
        ).called(1);
      });

      test('should pass correct genre ID to datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getTrendingByGenre(any()),
        ).thenAnswer((_) async => tGenreTabTracks);

        // Act
        await repository.getTrendingByGenre('pop');

        // Assert
        verify(() => mockRemoteDatasource.getTrendingByGenre('pop')).called(1);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getTrendingByGenre(any()),
        ).thenThrow(Exception('API error'));

        // Act & Assert
        expect(
          () => repository.getTrendingByGenre('electronic'),
          throwsException,
        );
      });
    });

    group('getHotForYou', () {
      test('should return HotForYou from remote datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getHotForYou(),
        ).thenAnswer((_) async => tHotForYou);

        // Act
        final result = await repository.getHotForYou();

        // Assert
        expect(result, tHotForYou);
        verify(() => mockRemoteDatasource.getHotForYou()).called(1);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getHotForYou(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getHotForYou(), throwsException);
      });
    });

    group('getMoreOfWhatYouLike', () {
      test('should return list of tracks from remote datasource', () async {
        // Arrange
        final tTracks = [tTrack];
        when(
          () => mockRemoteDatasource.getMoreOfWhatYouLike(),
        ).thenAnswer((_) async => tTracks);

        // Act
        final result = await repository.getMoreOfWhatYouLike();

        // Assert
        expect(result, tTracks);
        verify(() => mockRemoteDatasource.getMoreOfWhatYouLike()).called(1);
      });

      test('should return empty list when no tracks available', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMoreOfWhatYouLike(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getMoreOfWhatYouLike();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMoreOfWhatYouLike(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getMoreOfWhatYouLike(), throwsException);
      });
    });

    group('getMixedForYou', () {
      test(
        'should return list of mixed for you items from remote datasource',
        () async {
          // Arrange
          final items = [tMixedForYouItem];
          when(
            () => mockRemoteDatasource.getMixedForYou(),
          ).thenAnswer((_) async => items);

          // Act
          final result = await repository.getMixedForYou();

          // Assert
          expect(result, items);
          verify(() => mockRemoteDatasource.getMixedForYou()).called(1);
        },
      );

      test('should return empty list when no items available', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMixedForYou(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getMixedForYou();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMixedForYou(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getMixedForYou(), throwsException);
      });
    });

    group('getDiscoverStations', () {
      test(
        'should return list of discover stations from remote datasource',
        () async {
          // Arrange
          final stations = [tDiscoverStation];
          when(
            () => mockRemoteDatasource.getDiscoverStations(),
          ).thenAnswer((_) async => stations);

          // Act
          final result = await repository.getDiscoverStations();

          // Assert
          expect(result, stations);
          verify(() => mockRemoteDatasource.getDiscoverStations()).called(1);
        },
      );

      test('should return empty list when no stations available', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getDiscoverStations(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getDiscoverStations();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getDiscoverStations(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getDiscoverStations(), throwsException);
      });
    });

    group('getMixTracks', () {
      test(
        'should return list of tracks for mix ID from remote datasource',
        () async {
          // Arrange
          final tTracks = [tTrack];
          when(
            () => mockRemoteDatasource.getMixTracks(any()),
          ).thenAnswer((_) async => tTracks);

          // Act
          final result = await repository.getMixTracks('mix-1');

          // Assert
          expect(result, tTracks);
          verify(() => mockRemoteDatasource.getMixTracks('mix-1')).called(1);
        },
      );

      test('should pass correct mix ID to datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMixTracks(any()),
        ).thenAnswer((_) async => []);

        // Act
        await repository.getMixTracks('specific-mix-id');

        // Assert
        verify(
          () => mockRemoteDatasource.getMixTracks('specific-mix-id'),
        ).called(1);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getMixTracks(any()),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getMixTracks('mix-1'), throwsException);
      });
    });

    group('getRelatedTracks', () {
      test(
        'should return list of related tracks for track ID from remote datasource',
        () async {
          // Arrange
          final tTracks = [tTrack];
          when(
            () => mockRemoteDatasource.getRelatedTracks(any()),
          ).thenAnswer((_) async => tTracks);

          // Act
          final result = await repository.getRelatedTracks('track-1');

          // Assert
          expect(result, tTracks);
          verify(
            () => mockRemoteDatasource.getRelatedTracks('track-1'),
          ).called(1);
        },
      );

      test('should pass correct track ID to datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getRelatedTracks(any()),
        ).thenAnswer((_) async => []);

        // Act
        await repository.getRelatedTracks('specific-track-id');

        // Assert
        verify(
          () => mockRemoteDatasource.getRelatedTracks('specific-track-id'),
        ).called(1);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockRemoteDatasource.getRelatedTracks(any()),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getRelatedTracks('track-1'), throwsException);
      });
    });
  });

  group('HomeRepositoryImpl.mock', () {
    late HomeRepositoryImpl repository;
    late MockHomeMockDatasource mockMockDatasource;

    setUp(() {
      mockMockDatasource = MockHomeMockDatasource();
      repository = HomeRepositoryImpl.mock(mockMockDatasource);
      registerFallbackValue(tTrack);
      registerFallbackValue(<Track>[]);
      registerFallbackValue(<MixedForYouItem>[]);
      registerFallbackValue(<DiscoverStation>[]);
    });

    group('getHomeData', () {
      test('should return HomeData from mock datasource', () async {
        // Arrange
        when(
          () => mockMockDatasource.getHomeData(),
        ).thenAnswer((_) async => tHomeData);

        // Act
        final result = await repository.getHomeData();

        // Assert
        expect(result, tHomeData);
        verify(() => mockMockDatasource.getHomeData()).called(1);
      });
    });

    group('getTrendingByGenre', () {
      test('should return GenreTabTracks from mock datasource', () async {
        // Arrange
        when(
          () => mockMockDatasource.getTrendingByGenre(any()),
        ).thenAnswer((_) async => tGenreTabTracks);

        // Act
        final result = await repository.getTrendingByGenre('electronic');

        // Assert
        expect(result, tGenreTabTracks);
        verify(
          () => mockMockDatasource.getTrendingByGenre('electronic'),
        ).called(1);
      });
    });

    group('getHotForYou', () {
      test('should return HotForYou from mock datasource', () async {
        // Arrange
        when(
          () => mockMockDatasource.getHotForYou(),
        ).thenAnswer((_) async => tHotForYou);

        // Act
        final result = await repository.getHotForYou();

        // Assert
        expect(result, tHotForYou);
        verify(() => mockMockDatasource.getHotForYou()).called(1);
      });
    });

    group('getMoreOfWhatYouLike', () {
      test('should return list of tracks from mock datasource', () async {
        // Arrange
        when(
          () => mockMockDatasource.getMoreOfWhatYouLike(),
        ).thenAnswer((_) async => [tTrack]);

        // Act
        final result = await repository.getMoreOfWhatYouLike();

        // Assert
        expect(result.isNotEmpty, true);
        verify(() => mockMockDatasource.getMoreOfWhatYouLike()).called(1);
      });
    });

    group('getMixedForYou', () {
      test(
        'should return list of mixed for you items from mock datasource',
        () async {
          // Arrange
          when(
            () => mockMockDatasource.getMixedForYou(),
          ).thenAnswer((_) async => [tMixedForYouItem]);

          // Act
          final result = await repository.getMixedForYou();

          // Assert
          expect(result.isNotEmpty, true);
          verify(() => mockMockDatasource.getMixedForYou()).called(1);
        },
      );
    });

    group('getDiscoverStations', () {
      test(
        'should return list of discover stations from mock datasource',
        () async {
          // Arrange
          when(
            () => mockMockDatasource.getDiscoverStations(),
          ).thenAnswer((_) async => [tDiscoverStation]);

          // Act
          final result = await repository.getDiscoverStations();

          // Assert
          expect(result.isNotEmpty, true);
          verify(() => mockMockDatasource.getDiscoverStations()).called(1);
        },
      );
    });

    group('getMixTracks', () {
      test('should throw exception when using mock repository', () async {
        // Note: getMixTracks is always remote for mock repository
        expect(
          () => repository.getMixTracks('mix-1'),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('getRelatedTracks', () {
      test('should throw exception when using mock repository', () async {
        // Note: getRelatedTracks is always remote for mock repository
        expect(
          () => repository.getRelatedTracks('track-1'),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
