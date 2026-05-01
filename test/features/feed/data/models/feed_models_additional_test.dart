import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/feed/data/models/feed_dto.dart';
import 'package:rythmify/features/feed/data/models/home_dto.dart';

void main() {
  group('FeedUserModel.fromJson', () {
    test('parses full user json', () {
      final json = {
        'id': 'user-1',
        'username': 'alice',
        'displayName': 'Alice',
        'profile_picture': 'https://example.com/pfp.jpg',
        'followers': 123,
        'isVerified': true,
        'is_following': true,
      };

      final user = FeedUserModel.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.username, 'alice');
      expect(user.displayName, 'Alice');
      expect(user.avatar, 'https://example.com/pfp.jpg');
      expect(user.followers, 123);
      expect(user.isVerified, true);
      expect(user.isFollowing, true);
    });

    test('falls back displayName and avatar', () {
      final json = {
        'id': 'user-2',
        'username': 'bob',
      };

      final user = FeedUserModel.fromJson(json);

      expect(user.displayName, 'bob');
      expect(user.avatar, isNull);
      expect(user.followers, 0);
      expect(user.isVerified, false);
      expect(user.isFollowing, false);
    });
  });

  group('FeedTrackModel.fromJson', () {
    test('parses full track json with artist fallback', () {
      final json = {
        'id': 'track-1',
        'title': 'Track',
        'duration': 200,
        'play_count': 1000,
        'like_count': 100,
        'comment_count': 5,
        'cover_image': 'https://example.com/cover.jpg',
        'audio_url': 'https://example.com/audio.mp3',
        'user': {'username': 'artist1'},
      };

      final track = FeedTrackModel.fromJson(json);

      expect(track.id, 'track-1');
      expect(track.title, 'Track');
      expect(track.duration, 200);
      expect(track.playCount, 1000);
      expect(track.likeCount, 100);
      expect(track.commentCount, 5);
      expect(track.coverUrl, 'https://example.com/cover.jpg');
      expect(track.audioUrl, 'https://example.com/audio.mp3');
      expect(track.uploaderUsername, 'artist1');
    });

    test('falls back to empty strings when keys missing', () {
      final json = {'id': 't2', 'title': 'T2'};
      final track = FeedTrackModel.fromJson(json);
      expect(track.duration, 0);
      expect(track.playCount, 0);
      expect(track.likeCount, 0);
      expect(track.audioUrl, '');
      expect(track.uploaderUsername, '');
    });
  });

  group('FeedPlaylistModel.fromJson', () {
    test('parses playlist', () {
      final json = {
        'id': 'pl-1',
        'title': 'My Playlist',
        'coverUrl': 'https://example.com/cover.jpg',
        'trackCount': 10,
        'likeCount': 5,
        'repostCount': 2,
      };

      final pl = FeedPlaylistModel.fromJson(json);
      expect(pl.id, 'pl-1');
      expect(pl.title, 'My Playlist');
      expect(pl.coverUrl, 'https://example.com/cover.jpg');
      expect(pl.trackCount, 10);
      expect(pl.likeCount, 5);
      expect(pl.repostCount, 2);
    });
  });

  group('FeedItemModel.fromJson', () {
    test('parses item when track present', () {
      final json = {
        'id': 'item-1',
        'type': 'repost',
        'content_type': 'track',
        'created_at': '2024-01-01T00:00:00Z',
        'user': {
          'id': 'user-1',
          'username': 'poster',
          'displayName': 'Poster',
        },
        'track': {
          'id': 'track-1',
          'title': 'A',
          'duration': 120,
          'play_count': 10,
          'like_count': 1,
          'user': {'id': 'owner-1', 'username': 'owner'},
          'audio_url': 'https://example.com/a.mp3',
        }
      };

      final item = FeedItemModel.fromJson(json)!;
      expect(item.id, 'item-1');
      expect(item.type, 'repost');
      expect(item.contentType, 'track');
      expect(item.user.username, 'poster');
      expect(item.track.id, 'track-1');
      expect(item.track.uploaderUsername, 'owner');
      expect(item.track.audioUrl, 'https://example.com/a.mp3');
    });

    test('parses item when playlist provides track', () {
      final json = {
        'id': 'item-2',
        'type': 'playlist_post',
        'content_type': 'playlist',
        'created_at': '2024-01-02T00:00:00Z',
        'user': {'id': 'poster-2', 'username': 'poster2'},
        'playlist': {
          'id': 'pl-1',
          'title': 'pl',
          'tracks': [
            {
              'id': 'track-from-pl',
              'title': 'From PL',
              'user': {'id': 'owner-2', 'username': 'owner2'},
              'audio_url': 'https://example.com/pl.mp3',
            }
          ]
        }
      };

      final item = FeedItemModel.fromJson(json)!;
      expect(item.track.id, 'track-from-pl');
      expect(item.track.uploaderUsername, 'owner2');
      expect(item.playlist, isNotNull);
      expect(item.playlist!.id, 'pl-1');
    });

    test('returns null when no track available', () {
      final json = {
        'id': 'item-3',
        'type': 'something',
        'content_type': 'track',
        'created_at': '2024-01-03T00:00:00Z',
        'user': {'id': 'u', 'username': 'u'},
      };

      final item = FeedItemModel.fromJson(json);
      expect(item, isNull);
    });
  });

  group('HomeDto', () {
    test('parseTrack handles null', () {
      final t = HomeDto.parseTrack(null);
      expect(t.id, isNotNull);
    });

    test('parseDiscoverStation images map', () {
      final json = {
        'id': 's1',
        'name': 'Name',
        'artist_id': 'a1',
        'artist_name': 'Artist',
        'cover_image': 'c',
        'track_count': 1,
        'follower_count': 2,
        'images': {'left': 'l', 'center': 'c', 'right': 'r'}
      };
      final s = HomeDto.parseDiscoverStation(json);
      expect(s.id, 's1');
      expect(s.images.left, 'l');
      expect(s.images.center, 'c');
      expect(s.images.right, 'r');
    });

    test('parseDiscoverStation with no images', () {
      final json = {'id': 's2'};
      final s = HomeDto.parseDiscoverStation(json);
      expect(s.images.left, isNull);
      expect(s.name, '');
    });
  });
}
