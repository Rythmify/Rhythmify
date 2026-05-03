import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/data/models/comment_dto.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';

void main() {
  group('CommentDto', () {
    final tJson = {
      'comment_id': 'comment-123',
      'track_id': 'track-456',
      'user_id': 'user-789',
      'content': 'Great track!',
      'track_timestamp': 45000,
      'created_at': '2023-10-15T10:00:00.000Z',
      'like_count': 10,
      'is_liked_by_me': false,
      'reply_count': 2,
      'parent_comment_id': null,
      'author': {
        'display_name': 'John Doe',
        'avatar_url': 'https://example.com/pfp.png',
      },
    };

    final tCommentDto = CommentDto(
      id: 'comment-123',
      trackId: 'track-456',
      userId: 'user-789',
      userDisplayName: 'John Doe',
      userPfp: 'https://example.com/pfp.png',
      content: 'Great track!',
      timestamp: 45000,
      createdAt: '2023-10-15T10:00:00.000Z',
      likeCount: 10,
      isLikedByMe: false,
      replyCount: 2,
      parentCommentId: null,
    );

    test('fromJson should return a valid model', () {
      final result = CommentDto.fromJson(tJson);

      expect(result.id, 'comment-123');
      expect(result.trackId, 'track-456');
      expect(result.userDisplayName, 'John Doe');
      expect(result.userPfp, 'https://example.com/pfp.png');
      expect(result.content, 'Great track!');
      expect(result.timestamp, 45000);
      expect(result.createdAt, '2023-10-15T10:00:00.000Z');
      expect(result.likeCount, 10);
      expect(result.isLikedByMe, false);
      expect(result.replyCount, 2);
      expect(result.parentCommentId, null);
    });

    test('fromJson should handle missing optional fields with defaults', () {
      final jsonWithMissingFields = {
        'comment_id': 'comment-123',
        'track_id': 'track-456',
        'user_id': 'user-789',
        'content': 'Great track!',
        'created_at': '2023-10-15T10:00:00.000Z',
        // missing track_timestamp, like_count, is_liked_by_me, reply_count, author
      };

      final result = CommentDto.fromJson(jsonWithMissingFields);

      expect(result.userDisplayName, 'Unknown User');
      expect(result.userPfp, isNull);
      expect(result.timestamp, 0);
      expect(result.likeCount, 0);
      expect(result.isLikedByMe, false);
      expect(result.replyCount, 0);
    });

    test('toDomain should return a valid Comment entity', () {
      final result = tCommentDto.toDomain();

      expect(result, isA<Comment>());
      expect(result.id, tCommentDto.id);
      expect(result.trackId, tCommentDto.trackId);
      expect(result.userId, tCommentDto.userId);
      expect(result.userDisplayName, tCommentDto.userDisplayName);
      expect(result.userPfp, tCommentDto.userPfp);
      expect(result.content, tCommentDto.content);
      expect(result.trackTimestamp, tCommentDto.timestamp);
      expect(result.createdAt, DateTime.parse(tCommentDto.createdAt).toLocal());
      expect(result.likesCount, tCommentDto.likeCount);
      expect(result.isLikedByMe, tCommentDto.isLikedByMe);
      expect(result.replyCount, tCommentDto.replyCount);
      expect(result.parentId, tCommentDto.parentCommentId);
    });
  });
}
