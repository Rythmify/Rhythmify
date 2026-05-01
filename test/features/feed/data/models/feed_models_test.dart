import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/feed/data/models/feed_dto.dart';
import 'package:rythmify/features/feed/domain/entities/feed_item.dart';

void main() {
  group('FeedUserModel', () {
    final tUserJson = {
      'id': 'user-1',
      'username': 'testuser',
      'displayName': 'Test User',
      'profile_picture': 'https://example.com/avatar.jpg',
      'followers': 1000,
      'isVerified': true,
      'is_following': true,
    };

    test('should return valid FeedUserModel from JSON', () {
      // Act
      final result = FeedUserModel.fromJson(tUserJson);

      // Assert
      expect(result, isA<FeedUserModel>());
      expect(result.id, 'user-1');
      expect(result.username, 'testuser');
      expect(result.displayName, 'Test User');
      expect(result.avatar, 'https://example.com/avatar.jpg');
      expect(result.followers, 1000);
      expect(result.isVerified, true);
      expect(result.isFollowing, true);
    });

    test('should use username as displayName when displayName is missing', () {
      // Arrange
      final jsonWithoutDisplayName = {...tUserJson, 'displayName': null};

      // Act
      final result = FeedUserModel.fromJson(jsonWithoutDisplayName);

      // Assert
      expect(result.displayName, 'testuser');
    });

    test('should use profile_picture as avatar preference', () {
      // Arrange
      final jsonWithBothAvatars = {
        ...tUserJson,
        'profile_picture': 'https://example.com/picture.jpg',
        'avatar': 'https://example.com/avatar.jpg',
      };

      // Act
      final result = FeedUserModel.fromJson(jsonWithBothAvatars);

      // Assert
      expect(result.avatar, 'https://example.com/picture.jpg');
    });

    test('should fallback to avatar when profile_picture is null', () {
      // Arrange
      final jsonWithoutProfilePicture = {
        ...tUserJson,
        'profile_picture': null,
        'avatar': 'https://example.com/avatar.jpg',
      };

      // Act
      final result = FeedUserModel.fromJson(jsonWithoutProfilePicture);

      // Assert
      expect(result.avatar, 'https://example.com/avatar.jpg');
    });

    test('should provide defaults for missing optional fields', () {
      // Arrange
      final minimalJson = {'id': 'user-1', 'username': 'testuser'};

      // Act
      final result = FeedUserModel.fromJson(minimalJson);

      // Assert
      expect(result.displayName, 'testuser');
      expect(result.avatar, isNull);
      expect(result.followers, 0);
      expect(result.isVerified, false);
      expect(result.isFollowing, false);
    });

    test('should be instance of FeedUserEntity', () {
      // Act
      final result = FeedUserModel.fromJson(tUserJson);

      // Assert
      expect(result, isA<FeedUserEntity>());
    });
  });

  group('FeedTrackModel', () {
    final tTrackJson = {
      'id': 'track-1',
      'title': 'Test Track',
      'duration': 180,
      'play_count': 5000,
      'like_count': 500,
      'comment_count': 10,
      'cover_image': 'https://example.com/cover.jpg',
      'audio_url': 'https://example.com/audio.mp3',
      'stream_url': 'https://example.com/stream.mp3',
      'preview_url': 'https://example.com/preview.mp3',
      'artist': {'id': 'artist-1', 'username': 'artist', 'displayName': 'Artist'},
    };

    test('should return valid FeedTrackModel from JSON', () {
      // Act
      final result = FeedTrackModel.fromJson(tTrackJson);

      // Assert
      expect(result, isA<FeedTrackModel>());
      expect(result.id, 'track-1');
      expect(result.title, 'Test Track');
      expect(result.duration, 180);
      expect(result.playCount, 5000);
      expect(result.likeCount, 500);
      expect(result.commentCount, 10);
      expect(result.coverUrl, 'https://example.com/cover.jpg');
      expect(result.audioUrl, 'https://example.com/audio.mp3');
      expect(result.uploaderUsername, 'artist');
    });

    test('should provide defaults for missing fields', () {
      // Arrange
      final minimalJson = {
        'id': 'track-1',
        'title': 'Test Track',
        'audio_url': 'https://example.com/audio.mp3',
      };

      // Act
      final result = FeedTrackModel.fromJson(minimalJson);

      // Assert
      expect(result.duration, 0);
      expect(result.playCount, 0);
      expect(result.likeCount, 0);
      expect(result.commentCount, 0);
      expect(result.coverUrl, isNull);
      expect(result.streamUrl, isNull);
      expect(result.previewUrl, isNull);
      expect(result.uploaderUsername, '');
    });

    test('should prefer audio_url over audioUrl', () {
      // Arrange
      final jsonWithBothUrls = {
        ...tTrackJson,
        'audio_url': 'https://example.com/audio_snake.mp3',
        'audioUrl': 'https://example.com/audioCamel.mp3',
      };

      // Act
      final result = FeedTrackModel.fromJson(jsonWithBothUrls);

      // Assert
      expect(result.audioUrl, 'https://example.com/audio_snake.mp3');
    });

    test('should use user as fallback when artist is missing', () {
      // Arrange
      final jsonWithUserInsteadOfArtist = {
        ...tTrackJson,
        'artist': null,
        'user': {'username': 'user_uploader'},
      };

      // Act
      final result = FeedTrackModel.fromJson(jsonWithUserInsteadOfArtist);

      // Assert
      expect(result.uploaderUsername, 'user_uploader');
    });

    test('should handle empty artist/user gracefully', () {
      // Arrange
      final jsonWithoutArtistUser = {
        ...tTrackJson,
        'artist': null,
        'user': null,
      };

      // Act
      final result = FeedTrackModel.fromJson(jsonWithoutArtistUser);

      // Assert
      expect(result.uploaderUsername, '');
    });

    test('should be instance of FeedTrackEntity', () {
      // Act
      final result = FeedTrackModel.fromJson(tTrackJson);

      // Assert
      expect(result, isA<FeedTrackEntity>());
    });
  });

  group('FeedPlaylistModel', () {
    final tPlaylistJson = {
      'id': 'playlist-1',
      'title': 'Test Playlist',
      'coverUrl': 'https://example.com/playlist.jpg',
      'trackCount': 10,
      'likeCount': 100,
      'repostCount': 50,
    };

    test('should return valid FeedPlaylistModel from JSON', () {
      // Act
      final result = FeedPlaylistModel.fromJson(tPlaylistJson);

      // Assert
      expect(result, isA<FeedPlaylistModel>());
      expect(result.id, 'playlist-1');
      expect(result.title, 'Test Playlist');
      expect(result.coverUrl, 'https://example.com/playlist.jpg');
      expect(result.trackCount, 10);
      expect(result.likeCount, 100);
      expect(result.repostCount, 50);
    });

    test('should provide defaults for missing fields', () {
      // Arrange
      final minimalJson = {'id': 'playlist-1', 'title': 'Test Playlist'};

      // Act
      final result = FeedPlaylistModel.fromJson(minimalJson);

      // Assert
      expect(result.coverUrl, isNull);
      expect(result.trackCount, 0);
      expect(result.likeCount, 0);
      expect(result.repostCount, 0);
    });

    test('should be instance of FeedPlaylistEntity', () {
      // Act
      final result = FeedPlaylistModel.fromJson(tPlaylistJson);

      // Assert
      expect(result, isA<FeedPlaylistEntity>());
    });
  });

  group('FeedItemModel', () {
    final tUserJson = {
      'id': 'user-1',
      'username': 'testuser',
      'displayName': 'Test User',
      'followers': 1000,
      'isVerified': true,
    };

    final tTrackJson = {
      'id': 'track-1',
      'title': 'Test Track',
      'duration': 180,
      'play_count': 5000,
      'like_count': 500,
      'audio_url': 'https://example.com/audio.mp3',
      'artist': {'id': 'artist-1', 'username': 'artist', 'displayName': 'Artist'},
    };

    final tPlaylistJson = {
      'id': 'playlist-1',
      'title': 'Test Playlist',
      'trackCount': 10,
      'likeCount': 100,
      'repostCount': 50,
    };

    final tFeedItemJson = {
      'id': 'feed-1',
      'type': 'post',
      'content_type': 'track',
      'created_at': '2024-01-01T00:00:00Z',
      'user': tUserJson,
      'track': tTrackJson,
      'playlist': tPlaylistJson,
    };

    test('should return valid FeedItemModel from JSON', () {
      // Act
      final result = FeedItemModel.fromJson(tFeedItemJson);

      // Assert
      expect(result, isA<FeedItemModel>());
      expect(result?.id, 'feed-1');
      expect(result?.type, 'post');
      expect(result?.contentType, 'track');
      expect(result?.user.username, 'testuser');
      expect(result?.track.title, 'Test Track');
      expect(result?.playlist?.title, 'Test Playlist');
    });

    test('should return null when no track is available', () {
      // Arrange
      final jsonWithoutTrack = {
        ...tFeedItemJson,
        'track': null,
        'playlist': null,
      };

      // Act
      final result = FeedItemModel.fromJson(jsonWithoutTrack);

      // Assert
      expect(result, isNull);
    });

    test('should extract track from playlist when track is null', () {
      // Arrange
      final playlistWithTracks = {
        ...tPlaylistJson,
        'tracks': [tTrackJson],
      };
      final jsonWithPlaylistTrack = {
        ...tFeedItemJson,
        'track': null,
        'playlist': playlistWithTracks,
      };

      // Act
      final result = FeedItemModel.fromJson(jsonWithPlaylistTrack);

      // Assert
      expect(result, isNotNull);
      expect(result?.track.title, 'Test Track');
      expect(result?.playlist?.title, 'Test Playlist');
    });

    test('should use track owner from track when available', () {
      // Arrange
      final trackWithOwner = {
        ...tTrackJson,
        'user': {
          'id': 'track-owner-1',
          'username': 'track_owner',
          'displayName': 'Track Owner',
        },
      };
      final jsonWithTrackOwner = {...tFeedItemJson, 'track': trackWithOwner};

      // Act
      final result = FeedItemModel.fromJson(jsonWithTrackOwner);

      // Assert
      expect(result?.trackOwner.username, 'track_owner');
    });

    test('should fallback to track artist when user is not available', () {
      // Arrange
      final trackWithArtist = {
        ...tTrackJson,
        'user': null,
        'artist': {
          'id': 'artist-1',
          'username': 'artist_user',
          'displayName': 'Artist User',
        },
      };
      final jsonWithArtistFallback = {
        ...tFeedItemJson,
        'track': trackWithArtist,
      };

      // Act
      final result = FeedItemModel.fromJson(jsonWithArtistFallback);

      // Assert
      expect(result?.trackOwner.username, 'artist_user');
    });

    test('should fallback to feed user when track owner is not available', () {
      // Arrange
      final trackWithoutOwner = {...tTrackJson, 'user': null, 'artist': null};
      final jsonWithoutTrackOwner = {
        ...tFeedItemJson,
        'track': trackWithoutOwner,
      };

      // Act
      final result = FeedItemModel.fromJson(jsonWithoutTrackOwner);

      // Assert
      expect(result?.trackOwner.username, 'testuser');
    });

    test('should be instance of FeedItemEntity', () {
      // Act
      final result = FeedItemModel.fromJson(tFeedItemJson);

      // Assert
      expect(result, isA<FeedItemEntity>());
    });

    test('should parse createdAt to DateTime', () {
      // Act
      final result = FeedItemModel.fromJson(tFeedItemJson);

      // Assert
      expect(result?.createdAt, isA<DateTime>());
      expect(result?.createdAt.year, 2024);
      expect(result?.createdAt.month, 1);
      expect(result?.createdAt.day, 1);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final jsonWithoutPlaylist = {...tFeedItemJson, 'playlist': null};

      // Act
      final result = FeedItemModel.fromJson(jsonWithoutPlaylist);

      // Assert
      expect(result?.playlist, isNull);
      expect(result?.discoverLabel, isNull);
    });
  });
}
