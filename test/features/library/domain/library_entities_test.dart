import 'package:flutter_test/flutter_test.dart';
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
      final processing = UploadedTrack(
        id: 't1',
        title: 'Song',
        playCount: 0,
        likeCount: 0,
        isPublic: true,
        status: 'processing',
        createdAt: DateTime(2026, 1, 1),
      );
      final failed = UploadedTrack(
        id: 't2',
        title: 'Song',
        playCount: 0,
        likeCount: 0,
        isPublic: false,
        status: 'failed',
        createdAt: DateTime(2026, 1, 1),
      );
      final ready = UploadedTrack(
        id: 't3',
        title: 'Song',
        playCount: 0,
        likeCount: 0,
        isPublic: false,
        status: 'ready',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(processing.isProcessing, isTrue);
      expect(processing.isReady, isFalse);
      expect(failed.isFailed, isTrue);
      expect(ready.isReady, isTrue);
    });
  });
}
