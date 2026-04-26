import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/providers/player_dependency_providers.dart';
import '../../domain/entities/comment.dart';
import '../providers/track_comments_notifier.dart';
import '../providers/comment_replies_notifier.dart';
import '../../../../core/presentation/pages/report_page.dart';
import '../../../../features/feed/presentation/providers/feed_providers.dart';

/// A bottom sheet widget displaying contextual actions for a specific comment.
///
/// This Presentation layer widget allows users to interact with a comment, offering
/// options such as copying text, navigating to the author's profile, playing the
/// track from the comment's timestamp, deleting (if owned), reporting, or blocking.
class CommentActionBottomSheet extends ConsumerWidget {
  /// The [Comment] entity this action sheet is interacting with.
  final Comment comment;

  /// Creates a [CommentActionBottomSheet] for the given [comment].
  const CommentActionBottomSheet({super.key, required this.comment});

  void _copyComment(BuildContext context) {
    Clipboard.setData(ClipboardData(text: comment.content));
    Navigator.pop(context);
  }

  void _playFrom(BuildContext context, WidgetRef ref) {
    final position = Duration(seconds: comment.trackTimestamp);

    ref.read(playerStateProvider.notifier).seek(position);
    // Ensure it plays if paused
    ref.read(playTrackUseCaseProvider).call();
    Navigator.pop(context);
  }

  void _deleteComment(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    try {
      if (comment.parentId == null) {
        await ref
            .read(trackCommentsProvider(comment.trackId).notifier)
            .deleteComment(comment.id);
      } else {
        await ref
            .read(commentRepliesProvider(comment.parentId!).notifier)
            .deleteReply(comment.id, comment.trackId, comment.parentId!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comment deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete comment: $e')));
      }
    }
  }

  void _reportUser(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ReportPage(reportedContentId: comment.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isMe =
        authState is AuthAuthenticated && authState.user.id == comment.userId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${comment.userDisplayName} at ${TimeUtils.formatTrackTimestamp(comment.trackTimestamp)}',
                    style: AppTheme.bodyNormal.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.semiWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),

          // Row 2: Play from
          _buildActionRow(
            key: const Key('comment_action_play_from_inkwell'),
            icon: Icons.play_circle_outline,
            label:
                'Play from ${TimeUtils.formatTrackTimestamp(comment.trackTimestamp)}',
            onTap: () => _playFrom(context, ref),
          ),

          // Row 3: Go to profile
          _buildActionRow(
            key: const Key('comment_action_view_profile_inkwell'),
            icon: Icons.person_outline,
            label: 'View profile',
            onTap: () {
              playerCollapseNotifier.value?.call(); // Collapse player
              Navigator.pop(context); // Close bottom sheet
              context.pop(); // Close comments screen
              context.push('/home/profile/${comment.userId}');
            },
          ),

          // Row 4: Copy
          _buildActionRow(
            key: const Key('comment_action_copy_inkwell'),
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: () => _copyComment(context),
          ),

          if (isMe)
            // Row 5 (Me): Delete
            _buildActionRow(
              key: const Key('comment_action_delete_inkwell'),
              icon: Icons.delete_outline,
              label: 'Delete comment',
              onTap: () => _deleteComment(context, ref),
            )
          else ...[
            // Row 5 (Other): Report
            _buildActionRow(
              key: const Key('comment_action_report_inkwell'),
              icon: Icons.flag_outlined,
              label: 'Report user',
              onTap: () => _reportUser(context),
            ),

            // Row 6 (Other): Block/Unblock
            _buildActionRow(
              key: const Key('comment_action_toggle_block_inkwell'),
              icon: Icons.block,
              label: comment.isAuthorBlocked ? 'Unblock' : 'Block',
              onTap: () => _toggleBlock(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleBlock(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final shouldBlock = !comment.isAuthorBlocked;
    try {
      if (comment.parentId == null) {
        await ref
            .read(trackCommentsProvider(comment.trackId).notifier)
            .toggleBlockUser(comment.userId, shouldBlock: shouldBlock);
      } else {
        await ref
            .read(commentRepliesProvider(comment.parentId!).notifier)
            .toggleBlockUser(comment.userId, shouldBlock: shouldBlock);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shouldBlock ? 'User blocked' : 'User unblocked'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${shouldBlock ? 'block' : 'unblock'} user: $e',
            ),
          ),
        );
      }
    }
  }

  Widget _buildActionRow({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyNormal.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
