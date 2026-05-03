import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/feed/domain/entities/discover_station.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';
import 'package:rythmify/features/feed/domain/entities/mixed_for_you_item.dart';
import 'package:rythmify/features/feed/domain/entities/trending_by_genre_initial.dart';
import 'package:rythmify/features/feed/domain/repositories/home_repository.dart';
import 'package:rythmify/features/feed/domain/usecases/get_discover_stations.dart';
import 'package:rythmify/features/feed/domain/usecases/get_home_data.dart';
import 'package:rythmify/features/feed/domain/usecases/get_hot_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_mixed_playlists.dart';
import 'package:rythmify/features/feed/domain/usecases/get_mix_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_more__you_like.dart';
import 'package:rythmify/features/feed/domain/usecases/get_related_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_trending_tracks.dart';

// ============ Mock Classes ============
class MockHomeRepository extends Mock implements HomeRepository {}

// ============ Test Fixtures ============
final tTrack = Track(
  id: 'track-1',
  userId: 'user-1',
  title: 'Test Track',
  duration: const Duration(seconds: 180),
  playCount: 5000,
  likeCount: 500,
  commentCount: 10,
  genre: 'Electronic',
  coverImage: 'https://example.com/cover.jpg',
  audioUrl: 'https://example.com/audio.mp3',
  createdAt: DateTime(2024, 1, 1),
  artist: 'Test Artist',
);

final tTrackList = [
  tTrack,
  Track(
    id: 'track-2',
    userId: 'user-2',
    title: 'Another Track',
    duration: const Duration(seconds: 200),
    playCount: 3000,
    likeCount: 300,
    genre: 'Pop',
    coverImage: 'https://example.com/cover2.jpg',
    audioUrl: 'https://example.com/audio2.mp3',
    createdAt: DateTime(2024, 1, 2),
    artist: 'Another Artist',
  ),
];

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
  images: const StationImages(
    left: 'https://example.com/left.jpg',
    center: 'https://example.com/center.jpg',
    right: 'https://example.com/right.jpg',
  ),
);

final tGenreTab = GenreTab(genreId: 'genre-1', genreName: 'Electronic');

final tGenreTabTracks = GenreTabTracks(
  genreId: 'genre-1',
  genreName: 'Electronic',
  tracks: tTrackList,
);

final tHotForYou = HotForYou(
  track: tTrack,
  reason: 'Trending in your region',
  validUntil: DateTime(2024, 12, 31),
);

final tHomeData = HomeData(
  hotForYou: tHotForYou,
  trendingByGenre: TrendingByGenreInitial(
    genres: [tGenreTab],
    initialTab: tGenreTabTracks,
  ),
  moreOfWhatYouLike: tTrackList,
  mixedForYou: [tMixedForYouItem],
  discoverWithStations: [tDiscoverStation],
);

void main() {
  late MockHomeRepository mockHomeRepository;

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    registerFallbackValue(<Track>[]);
    registerFallbackValue(<MixedForYouItem>[]);
    registerFallbackValue(<DiscoverStation>[]);
  });

  group('GetHomeData', () {
    late GetHomeData usecase;

    setUp(() {
      usecase = GetHomeData(mockHomeRepository);
    });

    test('should return HomeData when repository call succeeds', () async {
      // Arrange
      when(
        () => mockHomeRepository.getHomeData(),
      ).thenAnswer((_) async => tHomeData);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tHomeData);
      expect(result.hotForYou, tHotForYou);
      expect(result.moreOfWhatYouLike.length, 2);
      expect(result.mixedForYou.length, 1);
      expect(result.discoverWithStations.length, 1);
      verify(() => mockHomeRepository.getHomeData()).called(1);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getHomeData(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
    });

    test('should return valid HomeData even with empty sections', () async {
      // Arrange
      final emptyHomeData = HomeData(
        hotForYou: tHotForYou,
        trendingByGenre: TrendingByGenreInitial(
          genres: [],
          initialTab: tGenreTabTracks,
        ),
        moreOfWhatYouLike: [],
        mixedForYou: [],
        discoverWithStations: [],
      );
      when(
        () => mockHomeRepository.getHomeData(),
      ).thenAnswer((_) async => emptyHomeData);

      // Act
      final result = await usecase();

      // Assert
      expect(result.moreOfWhatYouLike, isEmpty);
      verify(() => mockHomeRepository.getHomeData()).called(1);
    });
  });

  group('GetTrendingByGenre', () {
    late GetTrendingByGenre usecase;

    setUp(() {
      usecase = GetTrendingByGenre(mockHomeRepository);
    });

    test('should return GenreTabTracks with correct genreId', () async {
      // Arrange
      when(
        () => mockHomeRepository.getTrendingByGenre(any()),
      ).thenAnswer((_) async => tGenreTabTracks);

      // Act
      final result = await usecase('genre-1');

      // Assert
      expect(result, tGenreTabTracks);
      expect(result.genreId, 'genre-1');
      expect(result.genreName, 'Electronic');
      expect(result.tracks.length, 2);
      verify(() => mockHomeRepository.getTrendingByGenre('genre-1')).called(1);
    });

    test('should pass correct genre ID to repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getTrendingByGenre(any()),
      ).thenAnswer((_) async => tGenreTabTracks);

      // Act
      await usecase('pop-genre-id');

      // Assert
      verify(
        () => mockHomeRepository.getTrendingByGenre('pop-genre-id'),
      ).called(1);
    });

    test('should return empty tracks list when available', () async {
      // Arrange
      final emptyGenreTabTracks = GenreTabTracks(
        genreId: 'genre-1',
        genreName: 'Electronic',
        tracks: [],
      );
      when(
        () => mockHomeRepository.getTrendingByGenre(any()),
      ).thenAnswer((_) async => emptyGenreTabTracks);

      // Act
      final result = await usecase('genre-1');

      // Assert
      expect(result.tracks, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getTrendingByGenre(any()),
      ).thenThrow(Exception('API error'));

      // Act & Assert
      expect(() => usecase('genre-1'), throwsException);
    });
  });

  group('GetHotForYou', () {
    late GetHotForYou usecase;

    setUp(() {
      usecase = GetHotForYou(mockHomeRepository);
    });

    test('should return HotForYou when repository call succeeds', () async {
      // Arrange
      when(
        () => mockHomeRepository.getHotForYou(),
      ).thenAnswer((_) async => tHotForYou);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tHotForYou);
      expect(result.track, tTrack);
      expect(result.reason, 'Trending in your region');
      verify(() => mockHomeRepository.getHotForYou()).called(1);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getHotForYou(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
    });
  });

  group('GetMoreOfWhatYouLike', () {
    late GetMoreOfWhatYouLike usecase;

    setUp(() {
      usecase = GetMoreOfWhatYouLike(mockHomeRepository);
    });

    test('should return list of tracks', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMoreOfWhatYouLike(),
      ).thenAnswer((_) async => tTrackList);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tTrackList);
      expect(result.length, 2);
      verify(() => mockHomeRepository.getMoreOfWhatYouLike()).called(1);
    });

    test('should return empty list when no tracks available', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMoreOfWhatYouLike(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMoreOfWhatYouLike(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
    });
  });

  group('GetMixedForYou', () {
    late GetMixedForYou usecase;

    setUp(() {
      usecase = GetMixedForYou(mockHomeRepository);
    });

    test('should return list of mixed for you items', () async {
      // Arrange
      final items = [tMixedForYouItem];
      when(
        () => mockHomeRepository.getMixedForYou(),
      ).thenAnswer((_) async => items);

      // Act
      final result = await usecase();

      // Assert
      expect(result, items);
      expect(result.length, 1);
      expect(result.first.label, 'Electronic Mix');
      verify(() => mockHomeRepository.getMixedForYou()).called(1);
    });

    test('should return empty list when no items available', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixedForYou(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixedForYou(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
    });
  });

  group('GetDiscoverStations', () {
    late GetDiscoverStations usecase;

    setUp(() {
      usecase = GetDiscoverStations(mockHomeRepository);
    });

    test('should return list of discover stations', () async {
      // Arrange
      final stations = [tDiscoverStation];
      when(
        () => mockHomeRepository.getDiscoverStations(),
      ).thenAnswer((_) async => stations);

      // Act
      final result = await usecase();

      // Assert
      expect(result, stations);
      expect(result.length, 1);
      expect(result.first.name, 'Test Station');
      verify(() => mockHomeRepository.getDiscoverStations()).called(1);
    });

    test('should return empty list when no stations available', () async {
      // Arrange
      when(
        () => mockHomeRepository.getDiscoverStations(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getDiscoverStations(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
    });
  });

  group('GetMixTracks', () {
    late GetMixTracks usecase;

    setUp(() {
      usecase = GetMixTracks(mockHomeRepository);
    });

    test('should return list of tracks for mix ID', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixTracks(any()),
      ).thenAnswer((_) async => tTrackList);

      // Act
      final result = await usecase('mix-1');

      // Assert
      expect(result, tTrackList);
      expect(result.length, 2);
      verify(() => mockHomeRepository.getMixTracks('mix-1')).called(1);
    });

    test('should pass correct mix ID to repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixTracks(any()),
      ).thenAnswer((_) async => tTrackList);

      // Act
      await usecase('specific-mix-id');

      // Assert
      verify(
        () => mockHomeRepository.getMixTracks('specific-mix-id'),
      ).called(1);
    });

    test('should return empty list when no tracks for mix', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixTracks(any()),
      ).thenAnswer((_) async => []);

      // Act
      final result = await usecase('mix-1');

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getMixTracks(any()),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase('mix-1'), throwsException);
    });
  });

  group('GetRelatedTracks', () {
    late GetRelatedTracks usecase;

    setUp(() {
      usecase = GetRelatedTracks(mockHomeRepository);
    });

    test('should return list of related tracks for track ID', () async {
      // Arrange
      when(
        () => mockHomeRepository.getRelatedTracks(any()),
      ).thenAnswer((_) async => tTrackList);

      // Act
      final result = await usecase('track-1');

      // Assert
      expect(result, tTrackList);
      expect(result.length, 2);
      verify(() => mockHomeRepository.getRelatedTracks('track-1')).called(1);
    });

    test('should pass correct track ID to repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getRelatedTracks(any()),
      ).thenAnswer((_) async => tTrackList);

      // Act
      await usecase('specific-track-id');

      // Assert
      verify(
        () => mockHomeRepository.getRelatedTracks('specific-track-id'),
      ).called(1);
    });

    test('should return empty list when no related tracks', () async {
      // Arrange
      when(
        () => mockHomeRepository.getRelatedTracks(any()),
      ).thenAnswer((_) async => []);

      // Act
      final result = await usecase('track-1');

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockHomeRepository.getRelatedTracks(any()),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase('track-1'), throwsException);
    });
  });

  group('UseCase Failure Scenarios', () {
    test('GetHomeData should propagate specific exceptions', () async {
      final exception = Exception('Network Timeout');
      when(() => mockHomeRepository.getHomeData()).thenThrow(exception);

      final usecase = GetHomeData(mockHomeRepository);

      expect(() => usecase(), throwsA(isA<Exception>()));
    });

    test('GetTrendingByGenre should handle empty genre ID input', () async {
      when(
        () => mockHomeRepository.getTrendingByGenre(''),
      ).thenAnswer((_) async => tGenreTabTracks);

      final usecase = GetTrendingByGenre(mockHomeRepository);

      final result = await usecase('');
      expect(result, tGenreTabTracks);
      verify(() => mockHomeRepository.getTrendingByGenre('')).called(1);
    });

    test('GetMixTracks should handle empty mixId', () async {
      when(
        () => mockHomeRepository.getMixTracks(''),
      ).thenAnswer((_) async => []);

      final usecase = GetMixTracks(mockHomeRepository);

      final result = await usecase('');

      expect(result, isEmpty);
      verify(() => mockHomeRepository.getMixTracks('')).called(1);
    });
  });
}
