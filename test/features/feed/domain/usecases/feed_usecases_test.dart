import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/feed/domain/entities/feed_item.dart';
import 'package:rythmify/features/feed/domain/repositories/feed_repository.dart';
import 'package:rythmify/features/feed/domain/usecases/get_discover_feed_usecase.dart';
import 'package:rythmify/features/feed/domain/usecases/get_following_feed_usecase.dart';

// ============ Mock Classes ============
class MockFeedRepository extends Mock implements FeedRepository {}

// ============ Test Fixtures ============
final tFeedUser = FeedUserEntity(
  id: 'user-1',
  username: 'testuser',
  displayName: 'Test User',
  avatar: 'https://example.com/avatar.jpg',
  followers: 1000,
  isVerified: true,
  isFollowing: true,
);

final tFeedTrack = FeedTrackEntity(
  id: 'track-1',
  title: 'Test Track',
  duration: 180,
  playCount: 5000,
  likeCount: 500,
  commentCount: 10,
  coverUrl: 'https://example.com/cover.jpg',
  audioUrl: 'https://example.com/audio.mp3',
  streamUrl: 'https://example.com/stream.mp3',
  previewUrl: 'https://example.com/preview.mp3',
  uploaderUsername: 'uploader',
);

final tFeedPlaylist = FeedPlaylistEntity(
  id: 'playlist-1',
  title: 'Test Playlist',
  coverUrl: 'https://example.com/playlist.jpg',
  trackCount: 10,
  likeCount: 100,
  repostCount: 50,
);

final tFeedItem = FeedItemEntity(
  id: 'feed-1',
  type: 'track_post',
  contentType: 'track',
  createdAt: DateTime(2024, 1, 1),
  user: tFeedUser,
  trackOwner: tFeedUser,
  track: tFeedTrack,
  playlist: tFeedPlaylist,
  discoverLabel: 'Discovered for you',
);

final tFollowingFeedItem = FeedItemEntity(
  id: 'feed-2',
  type: 'repost',
  contentType: 'track',
  createdAt: DateTime(2024, 1, 2),
  user: tFeedUser,
  trackOwner: tFeedUser,
  track: tFeedTrack,
);

void main() {
  late MockFeedRepository mockFeedRepository;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    registerFallbackValue(<FeedItemEntity>[]);
  });

  group('GetFollowingFeedUseCase', () {
    late GetFollowingFeedUseCase usecase;

    setUp(() {
      usecase = GetFollowingFeedUseCase(mockFeedRepository);
    });

    test(
      'should return list of FeedItemEntity when repository call succeeds',
      () async {
        // Arrange
        final tFeedItems = [tFollowingFeedItem];
        when(
          () => mockFeedRepository.getFollowingFeed(),
        ).thenAnswer((_) async => tFeedItems);

        // Act
        final result = await usecase();

        // Assert
        expect(result, tFeedItems);
        expect(result.length, 1);
        expect(result.first.id, 'feed-2');
        verify(() => mockFeedRepository.getFollowingFeed()).called(1);
        verifyNoMoreInteractions(mockFeedRepository);
      },
    );

    test(
      'should return empty list when repository returns empty list',
      () async {
        // Arrange
        when(
          () => mockFeedRepository.getFollowingFeed(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await usecase();

        // Assert
        expect(result, isEmpty);
        verify(() => mockFeedRepository.getFollowingFeed()).called(1);
      },
    );

    test('should return multiple FeedItemEntity when available', () async {
      // Arrange
      final item1 = FeedItemEntity(
        id: 'feed-1',
        type: 'repost',
        contentType: 'track',
        createdAt: DateTime(2024, 1, 1),
        user: tFeedUser,
        trackOwner: tFeedUser,
        track: tFeedTrack,
      );
      final item2 = FeedItemEntity(
        id: 'feed-2',
        type: 'post',
        contentType: 'track',
        createdAt: DateTime(2024, 1, 2),
        user: tFeedUser,
        trackOwner: tFeedUser,
        track: tFeedTrack,
      );
      final tFeedItems = [item1, item2];
      when(
        () => mockFeedRepository.getFollowingFeed(),
      ).thenAnswer((_) async => tFeedItems);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tFeedItems);
      expect(result.length, 2);
      expect(result[0].id, 'feed-1');
      expect(result[1].id, 'feed-2');
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockFeedRepository.getFollowingFeed(),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
      verify(() => mockFeedRepository.getFollowingFeed()).called(1);
    });
  });

  group('GetDiscoverFeedUseCase', () {
    late GetDiscoverFeedUseCase usecase;

    setUp(() {
      usecase = GetDiscoverFeedUseCase(mockFeedRepository);
    });

    test(
      'should return list of FeedItemEntity when repository call succeeds',
      () async {
        // Arrange
        final tDiscoverItems = [tFeedItem];
        when(
          () => mockFeedRepository.getDiscoverFeed(),
        ).thenAnswer((_) async => tDiscoverItems);

        // Act
        final result = await usecase();

        // Assert
        expect(result, tDiscoverItems);
        expect(result.length, 1);
        expect(result.first.id, 'feed-1');
        expect(result.first.discoverLabel, 'Discovered for you');
        verify(() => mockFeedRepository.getDiscoverFeed()).called(1);
        verifyNoMoreInteractions(mockFeedRepository);
      },
    );

    test(
      'should return empty list when repository returns empty list',
      () async {
        // Arrange
        when(
          () => mockFeedRepository.getDiscoverFeed(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await usecase();

        // Assert
        expect(result, isEmpty);
        verify(() => mockFeedRepository.getDiscoverFeed()).called(1);
      },
    );

    test('should return items with discover labels', () async {
      // Arrange
      final item1 = FeedItemEntity(
        id: 'discover-1',
        type: 'discovery',
        contentType: 'track',
        createdAt: DateTime(2024, 1, 1),
        user: tFeedUser,
        trackOwner: tFeedUser,
        track: tFeedTrack,
        discoverLabel: 'Trending in Electronic',
      );
      final item2 = FeedItemEntity(
        id: 'discover-2',
        type: 'discovery',
        contentType: 'track',
        createdAt: DateTime(2024, 1, 2),
        user: tFeedUser,
        trackOwner: tFeedUser,
        track: tFeedTrack,
        discoverLabel: 'Popular in your region',
      );
      final tDiscoverItems = [item1, item2];
      when(
        () => mockFeedRepository.getDiscoverFeed(),
      ).thenAnswer((_) async => tDiscoverItems);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tDiscoverItems);
      expect(result.length, 2);
      expect(result[0].discoverLabel, 'Trending in Electronic');
      expect(result[1].discoverLabel, 'Popular in your region');
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(
        () => mockFeedRepository.getDiscoverFeed(),
      ).thenThrow(Exception('API error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
      verify(() => mockFeedRepository.getDiscoverFeed()).called(1);
    });

    test('should return items without playlist when not present', () async {
      // Arrange
      final itemWithoutPlaylist = FeedItemEntity(
        id: 'feed-no-playlist',
        type: 'post',
        contentType: 'track',
        createdAt: DateTime(2024, 1, 1),
        user: tFeedUser,
        trackOwner: tFeedUser,
        track: tFeedTrack,
        playlist: null,
      );
      when(
        () => mockFeedRepository.getDiscoverFeed(),
      ).thenAnswer((_) async => [itemWithoutPlaylist]);

      // Act
      final result = await usecase();

      // Assert
      expect(result.first.playlist, isNull);
      verify(() => mockFeedRepository.getDiscoverFeed()).called(1);
    });
  });
}
