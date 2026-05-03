import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/presentation/widgets/comment_reply_card.dart';
import 'package:rythmify/features/comments/presentation/widgets/comment_card.dart';

void main() {
  final tReply = Comment(
    id: 'reply-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Test Reply',
    trackTimestamp: 45000,
    createdAt: DateTime.now(),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 0,
    parentId: 'comment-123',
  );

  group('CommentReplyCard', () {
    testWidgets('renders CommentCard with isReply true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentReplyCard(reply: tReply),
          ),
        ),
      );

      final commentCardFinder = find.byType(CommentCard);
      expect(commentCardFinder, findsOneWidget);
      
      final commentCard = tester.widget<CommentCard>(commentCardFinder);
      expect(commentCard.isReply, isTrue);
      expect(commentCard.comment, tReply);
    });

    testWidgets('passes callbacks to CommentCard', (tester) async {
      bool likePressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentReplyCard(
              reply: tReply,
              onLike: () => likePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likePressed, isTrue);
    });
  });
}
