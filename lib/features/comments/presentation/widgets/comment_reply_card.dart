import 'package:flutter/material.dart';
import '../../domain/entities/comment.dart';
import 'comment_card.dart';

/// A UI widget that renders a single reply to a parent comment.
///
/// It acts as a specialized wrapper around [CommentCard] by automatically
/// configuring the card to render in a nested "reply" visual style.
class CommentReplyCard extends StatelessWidget {
  /// The [Comment] entity containing the reply's data.
  final Comment reply;

  /// Optional callback triggered when the user taps the like button.
  final VoidCallback? onLike;

  /// Optional callback triggered when the user taps the 'more' (options) button.
  final VoidCallback? onMore;

  /// Creates a [CommentReplyCard] to display a specific [reply].
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
