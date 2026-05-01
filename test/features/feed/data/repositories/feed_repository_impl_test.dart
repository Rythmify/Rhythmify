import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:rythmify/features/feed/data/models/feed_dto.dart';
import 'package:rythmify/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rythmify/features/feed/domain/entities/feed_item.dart';

// ============ Mock Classes ============
class MockFeedDatasource extends Mock implements FeedDatasource {}

// ============ Test Fixtures ============
final tFeedUserModel = FeedUserModel(
  id: 'user-1',
  username: 'testuser',
  displayName: 'Test User',
  avatar: 'https://example.com/avatar.jpg',
  followers: 1000,
  isVerified: true,
  isFollowing: true,
);

final tFeedTrackModel = FeedTrackModel(
  id: 'track-1',
  title: 'Test Track',
  duration: 180,
  playCount: 5000,
  likeCount: 500,
  commentCount: 10,
  coverUrl: 'https://example.com/cover.jpg',
  audioUrl: 'https://example.com/audio.mp3',
  uploaderUsername: 'uploader',
);

final tFeedItemModel = FeedItemModel(
  id: 'feed-1',
  type: 'post',
  contentType: 'track',
  createdAt: DateTime(2024, 1, 1),
  user: tFeedUserModel,
  trackOwner: tFeedUserModel,
  track: tFeedTrackModel,
);

void main() {
  late FeedRepositoryImpl repository;
  late MockFeedDatasource mockFeedDatasource;

  setUp(() {
    mockFeedDatasource = MockFeedDatasource();
    repository = FeedRepositoryImpl(mockFeedDatasource);
    registerFallbackValue(<FeedItemModel>[]);
  });

  group('FeedRepositoryImpl', () {
    group('getFollowingFeed', () {
      test('should return list of FeedItemEntity from datasource', () async {
        // Arrange
        final tFeedItems = [tFeedItemModel];
        when(
          () => mockFeedDatasource.getFollowingFeed(),
        ).thenAnswer((_) async => tFeedItems);

        // Act
        final result = await repository.getFollowingFeed();

        // Assert
        expect(result, isA<List<FeedItemEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 'feed-1');
        verify(() => mockFeedDatasource.getFollowingFeed()).called(1);
        verifyNoMoreInteractions(mockFeedDatasource);
      });

      test('should return empty list when datasource returns empty', () async {
        // Arrange
        when(
          () => mockFeedDatasource.getFollowingFeed(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getFollowingFeed();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockFeedDatasource.getFollowingFeed(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => repository.getFollowingFeed(), throwsException);
      });

      test('should return multiple items when available', () async {
        // Arrange
        final item1 = FeedItemModel(
          id: 'feed-1',
          type: 'post',
          contentType: 'track',
          createdAt: DateTime(2024, 1, 1),
          user: tFeedUserModel,
          trackOwner: tFeedUserModel,
          track: tFeedTrackModel,
        );
        final item2 = FeedItemModel(
          id: 'feed-2',
          type: 'repost',
          contentType: 'track',
          createdAt: DateTime(2024, 1, 2),
          user: tFeedUserModel,
          trackOwner: tFeedUserModel,
          track: tFeedTrackModel,
        );
        final tFeedItems = [item1, item2];
        when(
          () => mockFeedDatasource.getFollowingFeed(),
        ).thenAnswer((_) async => tFeedItems);

        // Act
        final result = await repository.getFollowingFeed();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'feed-1');
        expect(result[1].id, 'feed-2');
      });
    });

    group('getDiscoverFeed', () {
      test('should return list of FeedItemEntity from datasource', () async {
        // Arrange
        final discoverItem = FeedItemModel(
          id: 'discover-1',
          type: 'discovery',
          contentType: 'track',
          createdAt: DateTime(2024, 1, 1),
          user: tFeedUserModel,
          trackOwner: tFeedUserModel,
          track: tFeedTrackModel,
          discoverLabel: 'Trending in Electronic',
        );
        final tDiscoverItems = [discoverItem];
        when(
          () => mockFeedDatasource.getDiscoverFeed(),
        ).thenAnswer((_) async => tDiscoverItems);

        // Act
        final result = await repository.getDiscoverFeed();

        // Assert
        expect(result, isA<List<FeedItemEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 'discover-1');
        expect(result.first.discoverLabel, 'Trending in Electronic');
        verify(() => mockFeedDatasource.getDiscoverFeed()).called(1);
        verifyNoMoreInteractions(mockFeedDatasource);
      });

      test('should return empty list when datasource returns empty', () async {
        // Arrange
        when(
          () => mockFeedDatasource.getDiscoverFeed(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getDiscoverFeed();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions from datasource', () async {
        // Arrange
        when(
          () => mockFeedDatasource.getDiscoverFeed(),
        ).thenThrow(Exception('API error'));

        // Act & Assert
        expect(() => repository.getDiscoverFeed(), throwsException);
      });

      test('should handle items with null discover label', () async {
        // Arrange
        final itemWithoutLabel = FeedItemModel(
          id: 'discover-1',
          type: 'discovery',
          contentType: 'track',
          createdAt: DateTime(2024, 1, 1),
          user: tFeedUserModel,
          trackOwner: tFeedUserModel,
          track: tFeedTrackModel,
          discoverLabel: null,
        );
        when(
          () => mockFeedDatasource.getDiscoverFeed(),
        ).thenAnswer((_) async => [itemWithoutLabel]);

        // Act
        final result = await repository.getDiscoverFeed();

        // Assert
        expect(result.first.discoverLabel, isNull);
      });
    });
  });
}
