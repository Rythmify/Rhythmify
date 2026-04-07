import 'package:flutter/material.dart';
import '../../domain/entities/comment.dart';
import 'comment_card.dart';

class CommentReplyCard extends StatelessWidget {
  final Comment reply;
  final VoidCallback? onLike;
  final VoidCallback? onMore;

  const CommentReplyCard({
    super.key,
    required this.reply,
    this.onLike,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return CommentCard(
      comment: reply,
      onLike: onLike,
      onMore: onMore,
      isReply: true,
    );
  }
}
