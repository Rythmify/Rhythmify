import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unblock_provider.dart';

class BlockedUserWidget extends ConsumerWidget {
  final String participantId;
  const BlockedUserWidget({
    super.key,
    required this.participantId
    });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsetsGeometry.directional(bottom: 62,top: 20,start: 10,end: 10),// Adjust for keyboard
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve blocked this account and can\'t send messages to them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB3B3B3),
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()async{
                    await ref.read(unBlockProvider.notifier)
                          .unBlockUser(participantId: participantId);

                    ref.invalidate(isBlockedProvider(participantId));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User unblocked successfully')),
                      );
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    maximumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    )
                  ),
                  child: Text('Unblock')
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}