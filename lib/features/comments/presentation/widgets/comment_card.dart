import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../domain/entities/comment.dart';
import 'comment_action_bottom_sheet.dart';
import '../../../../features/feed/presentation/providers/feed_providers.dart';

/// A reusable UI widget that displays a standard comment or reply.
///
/// This Presentation layer widget renders a comment's author, timestamp, content,
/// and interactive elements like the 'like' button and 'reply' button.
class CommentCard extends StatelessWidget {
  /// The [Comment] entity containing the data to display.
  final Comment comment;

  /// Callback triggered when the like button is pressed.
  final VoidCallback? onLike;

  /// Callback triggered when the reply button is pressed.
  final VoidCallback? onReply;

  /// Callback triggered when the vertical ellipsis (more options).
  final VoidCallback? onMore;

  /// Callback triggered when the user toggles the "Show replies" dropdown.
  final VoidCallback? onShowReplies;

  /// Indicates whether this card is being rendered as a nested reply (adds left padding).
  final bool isReply;

  /// Whether the replies section for this comment is currently expanded.
  final bool isExpanded;

  /// Creates a [CommentCard] for the specified [comment].
  const CommentCard({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onMore,
    this.onShowReplies,
    this.isReply = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = comment.isAuthorBlocked;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 48.0 : 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: isBlocked ? 0.4 : 1.0,
            child: InkWell(
              onTap: isBlocked ? null : () {
                playerCollapseNotifier.value?.call(); // Collapse player
                context.pop(); // Close comments
                context.push('/home/profile/${comment.userId}');
              },
              borderRadius: BorderRadius.circular(isReply ? 16 : 20),
              child: Container(
                width: isReply ? 32 : 40,
                height: isReply ? 32 : 40,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: comment.userPfp == null || comment.userPfp!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isReply ? 16 : 20,
                        )
                      : (comment.userPfp!.startsWith('http') ||
                                comment.userPfp!.startsWith('https')
                            ? Image.network(
                                comment.userPfp!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: isReply ? 16 : 20,
                                    ),
                              )
                            : Image.asset(
                                comment.userPfp!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: isReply ? 16 : 20,
                                    ),
                              )),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Opacity(
                      opacity: isBlocked ? 0.4 : 1.0,
                      child: InkWell(
                        onTap: isBlocked ? null : () {
                playerCollapseNotifier.value?.call(); // Collapse player
                context.pop(); // Close comments
                context.push('/home/profile/${comment.userId}');
              },
                        borderRadius: BorderRadius.circular(
                          4,
                        ), // Gives the ripple a nice rounded edge
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 2.0,
                          ), // Slight padding so the ripple doesn't cut off the text
                          child: Text(
                            comment.userDisplayName,
                            style: AppTheme.bodyNormal.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Opacity(
                      opacity: isBlocked ? 0.4 : 1.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'at  ',
                            style: AppTheme.commentLabel.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              TimeUtils.formatTrackTimestamp(
                                comment.trackTimestamp,
                              ),
                              style: AppTheme.commentLabel.copyWith(
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('·', style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 4),
                    Text(
                      TimeUtils.formatRelativeDate(comment.createdAt),
                      style: AppTheme.commentLabel.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isBlocked)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'You blocked this user',
                      style: AppTheme.bodyNormal.copyWith(
                        fontSize: 14,
                        color: Colors.red.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Text(
                    comment.content,
                    style: AppTheme.bodyNormal.copyWith(fontSize: 14),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isReply && !isBlocked) ...[
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          'Reply',
                          style: AppTheme.commentLabel.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                    ],
                    InkWell(
                      onTap: () {
                        // Just open the bottom sheet directly
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              CommentActionBottomSheet(comment: comment),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 4.0,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),

                // This is what makes the main spacing between comments
                const SizedBox(height: 8),

                if (!isReply && comment.replyCount > 0)
                  TextButton.icon(
                    onPressed: onShowReplies,
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                    ),
                    label: Text(
                      isExpanded
                          ? 'Show less'
                          : 'Show ${comment.replyCount} replies',
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppTheme.primaryBrand,
                    ),
                  ),
              ],
            ),
          ),
          if (!isBlocked)
            Column(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    comment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: comment.isLikedByMe ? Colors.red : Colors.white70,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  comment.likesCount.toString(),
                  style: AppTheme.labelSmall.copyWith(fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
