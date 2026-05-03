import 'package:flutter/material.dart';

/// A confirmation dialog shown before blocking a user.
///
/// Returns `true` via [Navigator.pop] if the user confirms the block,
/// or `false` if they cancel. The result is handled by [PopUpMenuWidget]
/// to proceed with or abort the block action.
class ConfirmBlock extends StatelessWidget {
  const ConfirmBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2F2F2F),
      title: const Text('Block user?', style: TextStyle(color: Colors.white)),
      content: const Text(
        'This user will no longer be able to follow or interact with you, and you will not see notifications from them',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'BLOCK',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ),
      ],
    );
  }
}
