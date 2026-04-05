import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../domain/entities/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onMore;
  final VoidCallback? onShowReplies;
  final bool isReply;
  final bool isExpanded;

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
          Container(
            width: isReply ? 32 : 40,
            height: isReply ? 32 : 40,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: comment.userPfp == null
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
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: Colors.white,
                              size: isReply ? 16 : 20,
                            ),
                          )
                        : Image.asset(
                            comment.userPfp!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: Colors.white,
                              size: isReply ? 16 : 20,
                            ),
                          )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userDisplayName,
                      style: AppTheme.bodyNormal.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
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
                Text(
                  comment.content,
                  style: AppTheme.bodyNormal.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isReply) ...[
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
                    GestureDetector(
                      onTap: onMore,
                      child: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Colors.white70,
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
