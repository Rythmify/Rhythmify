import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/confirm_block_widget.dart';

/// A bottom sheet widget providing moderation actions for a conversation participant.
///
/// Currently supports:
/// - Block: calls [BlockNotifier] to block the participant, invalidates
///   [isBlockedProvider], and dismisses the sheet.
/// - Report: navigates to the report screen (not yet implemented).
///
/// Requires [participantId] to identify the target user and [parentContext]
/// to handle navigation after dismissal.
class PopUpMenuWidget extends ConsumerWidget {
  final String participantId;
  final BuildContext parentContext;
  final VoidCallback? onBlocked;

  const PopUpMenuWidget({
    super.key,
    required this.participantId,
    required this.parentContext,
    this.onBlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 60), // Adjust for keyboard
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              //Block user
              leading: const Icon(Icons.block, color: Colors.white),
              title: const Text(
                'Block user',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                final shouldBlock = await showDialog<bool>(
                  context: parentContext,
                  builder: (parentContext) => const ConfirmBlock(),
                );

                if (shouldBlock == true) {
                  try {
                    await ref
                        .read(blockUserProvider.notifier)
                        .blockUser(participantId: participantId);

                    ref.invalidate(isBlockedProvider(participantId));
                    onBlocked?.call();

                    if (context.mounted) Navigator.pop(context);

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('User blocked successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to block user. Please try again.',
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),

            ListTile(
              //Report user
              leading: const Icon(Icons.flag_outlined, color: Colors.white),
              title: const Text(
                'Report user',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
