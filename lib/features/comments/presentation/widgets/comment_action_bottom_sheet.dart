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
import '../providers/comment_di_providers.dart';
import '../../../../core/presentation/pages/report_page.dart';

class CommentActionBottomSheet extends ConsumerWidget {
  final Comment comment;

  const CommentActionBottomSheet({
    super.key,
    required this.comment,
  });

  void _copyComment(BuildContext context) {
    Clipboard.setData(ClipboardData(text: comment.content));
    Navigator.pop(context);
  }

  void _goToProfile(BuildContext context) {
    Navigator.pop(context);
    context.push('/profile/${comment.userId}');
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
      await ref.read(deleteCommentProvider)(comment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
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

  void _blockUser(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    try {
      await ref.read(blockUserProvider)(comment.userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User blocked')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to block user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isMe = authState is AuthAuthenticated && authState.user.id == comment.userId;

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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${comment.userDisplayName} at ${TimeUtils.formatTrackTimestamp(comment.trackTimestamp)}',
                    style: AppTheme.bodyNormal.copyWith(
                      fontWeight: FontWeight.bold,
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
            icon: Icons.play_circle_outline,
            label: 'Play from ${TimeUtils.formatTrackTimestamp(comment.trackTimestamp)}',
            onTap: () => _playFrom(context, ref),
          ),

          // Row 3: Go to profile
          _buildActionRow(
            icon: Icons.person_outline,
            label: 'Go to profile',
            onTap: () => _goToProfile(context),
          ),

          // Row 4: Copy
          _buildActionRow(
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: () => _copyComment(context),
          ),

          if (isMe)
            // Row 5 (Me): Delete
            _buildActionRow(
              icon: Icons.delete_outline,
              label: 'Delete comment',
              onTap: () => _deleteComment(context, ref),
            )
          else ...[
            // Row 5 (Other): Report
            _buildActionRow(
              icon: Icons.flag_outlined,
              label: 'Report user',
              onTap: () => _reportUser(context),
            ),
            
            // Row 6 (Other): Block
            _buildActionRow(
              icon: Icons.block,
              label: 'Block',
              onTap: () => _blockUser(context, ref),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
