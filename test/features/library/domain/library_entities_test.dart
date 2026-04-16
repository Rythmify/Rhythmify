import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/library/domain/entities/library_entities.dart';

void main() {
  group('Library entities', () {
    test('FollowedUser equality includes key identity fields', () {
      const a = FollowedUser(
        id: 'u1',
        displayName: 'User',
        followersCount: 10,
        isVerified: true,
        username: 'first',
      );
      const b = FollowedUser(
        id: 'u1',
        displayName: 'User',
        followersCount: 10,
        isVerified: true,
        username: 'second',
      );

      expect(a, b);
    });

    test('UploadedTrack status helpers map correctly', () {
      final t = Track(
        id: 't1',
        userId: 'u',
        title: 'Song',
        artist: 'Artist',
        audioUrl: '',
        duration: Duration.zero,
        createdAt: DateTime(2026, 1, 1),
      );
      final processing = UploadedTrack(
        track: t,
        isPublic: true,
        status: 'processing',
      );
      final failed = UploadedTrack(track: t, isPublic: false, status: 'failed');
      final ready = UploadedTrack(track: t, isPublic: false, status: 'ready');

      expect(processing.isProcessing, isTrue);
      expect(processing.isReady, isFalse);
      expect(failed.isFailed, isTrue);
      expect(ready.isReady, isTrue);
    });
  });
}
