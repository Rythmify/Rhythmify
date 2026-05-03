import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/data/datasources/comment_local_datasource.dart';
import 'package:rythmify/features/comments/data/models/comment_dto.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mockAssetPath = 'assets/mocks/mock_comments.json';

  final commentsJson = [
    {
      'comment_id': 'root-new',
      'track_id': 'track-1',
      'user_id': 'user-1',
      'content': 'new comment',
      'track_timestamp': 30,
      'created_at': '2024-01-03T00:00:00.000Z',
      'like_count': 1,
      'is_liked_by_me': false,
      'reply_count': 1,
      'parent_comment_id': null,
      'author': {'display_name': 'New User', 'avatar_url': 'new.png'},
    },
    {
      'comment_id': 'root-old',
      'track_id': 'track-1',
      'user_id': 'user-2',
      'content': 'old comment',
      'track_timestamp': 10,
      'created_at': '2024-01-01T00:00:00.000Z',
      'like_count': 9,
      'is_liked_by_me': true,
      'reply_count': 0,
      'parent_comment_id': null,
      'author': {'display_name': 'Old User', 'avatar_url': null},
    },
    {
      'comment_id': 'root-mid',
      'track_id': 'track-1',
      'user_id': 'user-3',
      'content': 'mid comment',
      'track_timestamp': 20,
      'created_at': '2024-01-02T00:00:00.000Z',
      'like_count': 4,
      'is_liked_by_me': false,
      'reply_count': 0,
      'parent_comment_id': null,
      'author': {'display_name': 'Mid User', 'avatar_url': null},
    },
    {
      'comment_id': 'reply-old',
      'track_id': 'track-1',
      'user_id': 'user-4',
      'content': 'old reply',
      'track_timestamp': 30,
      'created_at': '2024-01-01T12:00:00.000Z',
      'like_count': 0,
      'is_liked_by_me': false,
      'reply_count': 0,
      'parent_comment_id': 'root-new',
      'author': {'display_name': 'Reply Old', 'avatar_url': null},
    },
    {
      'comment_id': 'reply-new',
      'track_id': 'track-1',
      'user_id': 'user-5',
      'content': 'new reply',
      'track_timestamp': 30,
      'created_at': '2024-01-04T00:00:00.000Z',
      'like_count': 2,
      'is_liked_by_me': false,
      'reply_count': 0,
      'parent_comment_id': 'root-new',
      'author': {'display_name': 'Reply New', 'avatar_url': null},
    },
    {
      'comment_id': 'other-track',
      'track_id': 'track-2',
      'user_id': 'user-6',
      'content': 'other track',
      'track_timestamp': 5,
      'created_at': '2024-01-05T00:00:00.000Z',
      'like_count': 0,
      'is_liked_by_me': false,
      'reply_count': 0,
      'parent_comment_id': null,
      'author': {'display_name': 'Other', 'avatar_url': null},
    },
  ];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key != mockAssetPath) return null;

          final bytes = Uint8List.fromList(
            utf8.encode(jsonEncode(commentsJson)),
          );
          return ByteData.sublistView(bytes);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('MockCommentLocalDataSourceImpl', () {
    test('loads root comments with sorting and pagination', () async {
      final dataSource = MockCommentLocalDataSourceImpl();

      final newest = await dataSource.getTrackComments(
        trackId: 'track-1',
        page: 1,
        limit: 2,
        sortValue: 'newest',
      );
      final oldest = await dataSource.getTrackComments(
        trackId: 'track-1',
        page: 1,
        limit: 3,
        sortValue: 'oldest',
      );
      final top = await dataSource.getTrackComments(
        trackId: 'track-1',
        page: 1,
        limit: 3,
        sortValue: 'top',
      );
      final emptyPage = await dataSource.getTrackComments(
        trackId: 'track-1',
        page: 5,
        limit: 2,
        sortValue: 'newest',
      );

      expect(newest.map((c) => c.id), ['root-new', 'root-mid']);
      expect(oldest.map((c) => c.id), ['root-old', 'root-mid', 'root-new']);
      expect(top.map((c) => c.id), ['root-old', 'root-mid', 'root-new']);
      expect(emptyPage, isEmpty);
    });

    test('loads replies through both reply APIs', () async {
      final dataSource = MockCommentLocalDataSourceImpl();

      final oldestReplies = await dataSource.getCommentReplies(
        commentId: 'root-new',
        page: 1,
        limit: 10,
        sortValue: 'oldest',
      );
      final pagedReplies = await dataSource.getReplies(
        commentId: 'root-new',
        limit: 1,
        offset: 1,
      );
      final emptyReplies = await dataSource.getReplies(
        commentId: 'root-new',
        limit: 1,
        offset: 50,
      );

      expect(oldestReplies.map((c) => c.id), ['reply-old', 'reply-new']);
      expect(pagedReplies.single.id, 'reply-old');
      expect(emptyReplies, isEmpty);
    });

    test('gets all comments for track including replies', () async {
      final dataSource = MockCommentLocalDataSourceImpl();

      final comments = await dataSource.getAllCommentsForTrack('track-1');

      expect(comments.map((c) => c.id), containsAll(['root-new', 'reply-new']));
      expect(comments.map((c) => c.id), isNot(contains('other-track')));
    });

    test(
      'insertComment stores roots and increments parent reply counts',
      () async {
        final dataSource = MockCommentLocalDataSourceImpl();
        final root = CommentDto(
          id: 'inserted-root',
          trackId: 'track-1',
          userId: 'me',
          userDisplayName: 'Me',
          content: 'inserted root',
          timestamp: 99,
          createdAt: '2024-01-06T00:00:00.000Z',
          likeCount: 0,
          isLikedByMe: false,
          replyCount: 0,
        );
        final reply = CommentDto(
          id: 'inserted-reply',
          trackId: 'track-1',
          userId: 'me',
          userDisplayName: 'Me',
          content: 'inserted reply',
          timestamp: 99,
          createdAt: '2024-01-06T00:00:00.000Z',
          likeCount: 0,
          isLikedByMe: false,
          replyCount: 0,
          parentCommentId: 'root-new',
        );

        expect(await dataSource.insertComment(root), root);
        expect(await dataSource.insertComment(reply), reply);

        final roots = await dataSource.getTrackComments(
          trackId: 'track-1',
          page: 1,
          limit: 10,
          sortValue: 'newest',
        );
        final parent = roots.singleWhere((comment) => comment.id == 'root-new');

        expect(roots.map((c) => c.id), contains('inserted-root'));
        expect(parent.replyCount, 2);
      },
    );

    test(
      'postReply creates a current user reply and increments parent',
      () async {
        final dataSource = MockCommentLocalDataSourceImpl();

        final reply = await dataSource.postReply(
          commentId: 'root-new',
          content: 'generated reply',
        );

        final roots = await dataSource.getTrackComments(
          trackId: 'track-1',
          page: 1,
          limit: 10,
          sortValue: 'newest',
        );
        expect(reply.parentCommentId, 'root-new');
        expect(reply.content, 'generated reply');
        expect(reply.userId, 'current_user_id');
        expect(roots.singleWhere((c) => c.id == 'root-new').replyCount, 2);
      },
    );

    test('toggleLike updates the comment and throws for missing ids', () async {
      final dataSource = MockCommentLocalDataSourceImpl();

      expect(await dataSource.toggleLike('root-mid'), true);
      expect(await dataSource.toggleLike('root-mid'), false);
      expect(
        () => dataSource.toggleLike('missing-comment'),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteComment removes comments and block calls complete', () async {
      final dataSource = MockCommentLocalDataSourceImpl();

      await dataSource.deleteComment('root-mid');
      await dataSource.blockUser('user-2');
      await dataSource.unblockUser('user-2');

      final roots = await dataSource.getTrackComments(
        trackId: 'track-1',
        page: 1,
        limit: 10,
        sortValue: 'newest',
      );
      expect(roots.map((c) => c.id), isNot(contains('root-mid')));
    });
  });
}
