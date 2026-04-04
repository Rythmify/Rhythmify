import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/confirm_block_widget.dart';

class PopUpMenuWidget extends ConsumerWidget {
  final String participantId;
  final BuildContext parentContext;

  const PopUpMenuWidget({
    super.key, 
    required this.participantId,
    required this.parentContext
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding
    (
      padding: EdgeInsetsGeometry.only(bottom: 60),// Adjust for keyboard
      child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile( //Block user
            leading: const Icon(Icons.block, color: Colors.white),
            title: const Text(
              'Block user', 
              style: TextStyle(color: Colors.white)
            ),
            onTap: () async {
              final shouldBlock = await showDialog<bool>(
                context: parentContext,
                builder: (parentContext) => const ConfirmBlock(),
              );
              if(context.mounted)
              {
                Navigator.pop(context);
              }

              if (shouldBlock == true) {
                await ref.read(blockUserProvider.notifier).blockUser(participantId: participantId);

                ref.invalidate(isBlockedProvider(participantId));

                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('User blocked successfully')),
                  );
                }
              }
            },
          ),

          ListTile( //Report user
            leading: const Icon(Icons.flag_outlined, color: Colors.white),
            title: const Text(
              'Report user',
              style: TextStyle(color: Colors.white)
            ),
            onTap: () async {
              Navigator.pop(context);
            },
          ),
        ],
      )
    )
    );
  }
}