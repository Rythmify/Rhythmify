import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test fixtures
  // ---------------------------------------------------------------------------

  final tCreatedAt = DateTime(2023, 10, 15);

  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    userPfp: 'https://example.com/pfp.png',
    content: 'Great track!',
    trackTimestamp: 45000,
    createdAt: tCreatedAt,
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 2,
    parentId: null,
  );

  final tReplyComment = Comment(
    id: 'comment-124',
    trackId: 'track-456',
    userId: 'user-999',
    userDisplayName: 'Jane Smith',
    userPfp: null,
    content: 'I agree!',
    trackTimestamp: 45000,
    createdAt: tCreatedAt,
    likesCount: 0,
    isLikedByMe: true,
    replyCount: 0,
    parentId: 'comment-123',
  );

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  group('Comment Entity — construction', () {
    test('should create a Comment with all fields set correctly', () {
      expect(tComment.id, 'comment-123');
      expect(tComment.trackId, 'track-456');
      expect(tComment.userId, 'user-789');
      expect(tComment.userDisplayName, 'John Doe');
      expect(tComment.userPfp, 'https://example.com/pfp.png');
      expect(tComment.content, 'Great track!');
      expect(tComment.trackTimestamp, 45000);
      expect(tComment.createdAt, tCreatedAt);
      expect(tComment.likesCount, 10);
      expect(tComment.isLikedByMe, false);
      expect(tComment.replyCount, 2);
      expect(tComment.parentId, isNull);
    });

    test('should allow optional fields to be null', () {
      expect(tReplyComment.userPfp, isNull);
      expect(tReplyComment.parentId, 'comment-123');
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  group('Comment Entity — copyWith', () {
    test('should return a new instance with updated fields', () {
      final updatedDate = DateTime(2023, 10, 16);
      final updated = tComment.copyWith(
        id: 'new-id',
        trackId: 'new-track',
        userId: 'new-user',
        userDisplayName: 'New Name',
        userPfp: 'new-pfp',
        content: 'New content',
        trackTimestamp: 1000,
        createdAt: updatedDate,
        likesCount: 15,
        isLikedByMe: true,
        replyCount: 5,
        parentId: 'parent-id',
      );

      expect(updated.id, 'new-id');
      expect(updated.trackId, 'new-track');
      expect(updated.userId, 'new-user');
      expect(updated.userDisplayName, 'New Name');
      expect(updated.userPfp, 'new-pfp');
      expect(updated.content, 'New content');
      expect(updated.trackTimestamp, 1000);
      expect(updated.createdAt, updatedDate);
      expect(updated.likesCount, 15);
      expect(updated.isLikedByMe, true);
      expect(updated.replyCount, 5);
      expect(updated.parentId, 'parent-id');
    });

    test('should preserve existing fields when not provided to copyWith', () {
      final updated = tComment.copyWith(likesCount: 99);

      expect(updated.id, tComment.id);
      expect(updated.trackId, tComment.trackId);
      expect(updated.userId, tComment.userId);
      expect(updated.userDisplayName, tComment.userDisplayName);
      expect(updated.userPfp, tComment.userPfp);
      expect(updated.content, tComment.content);
      expect(updated.trackTimestamp, tComment.trackTimestamp);
      expect(updated.createdAt, tComment.createdAt);
      expect(updated.likesCount, 99);
      expect(updated.isLikedByMe, tComment.isLikedByMe);
      expect(updated.replyCount, tComment.replyCount);
      expect(updated.parentId, tComment.parentId);
    });
  });

  // ---------------------------------------------------------------------------
  // Equality (Equatable)
  // ---------------------------------------------------------------------------

  group('Comment Entity — equality', () {
    test('should return true when two instances have identical fields', () {
      final duplicate = Comment(
        id: 'comment-123',
        trackId: 'track-456',
        userId: 'user-789',
        userDisplayName: 'John Doe',
        userPfp: 'https://example.com/pfp.png',
        content: 'Great track!',
        trackTimestamp: 45000,
        createdAt: tCreatedAt,
        likesCount: 10,
        isLikedByMe: false,
        replyCount: 2,
        parentId: null,
      );
      expect(tComment, equals(duplicate));
    });

    test('should return false when fields differ', () {
      final different = tComment.copyWith(id: 'different-id');
      expect(tComment, isNot(equals(different)));
    });
  });

  // ---------------------------------------------------------------------------
  // props
  // ---------------------------------------------------------------------------

  group('Comment Entity — props', () {
    test('should expose all 13 fields in props', () {
      expect(tComment.props.length, 13);
    });

    test('should include null fields in props', () {
      expect(tReplyComment.props, contains(null));
    });
  });
}
