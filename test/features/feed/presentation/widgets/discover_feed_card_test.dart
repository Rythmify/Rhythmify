import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/feed/domain/entities/feed_item.dart';

void main() {
  group('DiscoverFeedCard Widget', () {
    late FeedUserEntity tArtist;
    late FeedTrackEntity tTrack;

    setUp(() {
      tArtist = FeedUserEntity(
        id: 'artist-1',
        username: 'artist',
        displayName: 'Test Artist',
        avatar: 'https://example.com/avatar.jpg',
        followers: 5000,
        isVerified: false,
        isFollowing: false,
      );

      tTrack = FeedTrackEntity(
        id: 'discover-track-1',
        title: 'Discover Track',
        duration: 240,
        playCount: 3000,
        likeCount: 200,
        commentCount: 5,
        coverUrl: 'https://example.com/discover-cover.jpg',
        audioUrl: 'https://example.com/discover-audio.mp3',
        uploaderUsername: 'artist',
      );
    });
  });
}
