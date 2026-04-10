import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/library/data/models/library_models.dart';

void main() {
  group('Library models', () {
    test('FollowedUserModel.fromJson handles user_id and profile_picture', () {
      final model = FollowedUserModel.fromJson({
        'user_id': 'u-1',
        'display_name': 'Karim',
        'profile_picture': 'https://img',
        'followers_count': 11,
        'is_verified': true,
      });

      expect(model.id, 'u-1');
      expect(model.avatarUrl, 'https://img');
      expect(model.isVerified, isTrue);
    });

    test('LibraryPlaylistModel.fromJson uses playlist_id and created_at', () {
      final model = LibraryPlaylistModel.fromJson({
        'playlist_id': 'pl-1',
        'name': 'My Playlist',
        'track_count': 3,
        'created_at': '2026-01-01T00:00:00.000Z',
      }, isOwned: false);

      expect(model.id, 'pl-1');
      expect(model.isOwned, isFalse);
      expect(model.createdAt.year, 2026);
    });

    test('UploadedTrackModel.fromJson falls back to cover_image', () {
      final model = UploadedTrackModel.fromJson({
        'id': 't-1',
        'title': 'Track',
        'cover_image': 'https://cover',
      });

      expect(model.artworkUrl, 'https://cover');
      expect(model.status, 'ready');
    });

    test('TrackInsightModel.fromTrack computes uniqueListeners', () {
      final model = TrackInsightModel.fromTrack({
        'id': 't-1',
        'title': 'Track',
        'play_count': 11,
        'like_count': 3,
      });

      expect(model.trackId, 't-1');
      expect(model.uniqueListeners, 5);
      expect(model.likes, 3);
    });

    test('RecentlyPlayedEntryModel.fromJson supports nested track payload', () {
      final model = RecentlyPlayedEntryModel.fromJson({
        'last_played_at': '2026-02-01T00:00:00.000Z',
        'track': {
          'id': 't-2',
          'title': 'Nested',
          'artist': 'Artist',
          'duration': 180,
        },
      });

      expect(model.trackId, 't-2');
      expect(model.artistName, 'Artist');
      expect(model.durationSeconds, 180);
    });

    test('LibraryStationModel.fromJson reads seed artist', () {
      final model = LibraryStationModel.fromJson({
        'id': 's-1',
        'name': 'Station',
        'seed_artist': {'display_name': 'Bassel'},
      });

      expect(model.id, 's-1');
      expect(model.seedArtistName, 'Bassel');
      expect(model.trackCount, 50);
    });
  });
}
