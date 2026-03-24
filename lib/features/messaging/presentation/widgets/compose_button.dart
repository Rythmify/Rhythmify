import 'package:flutter/material.dart';

class ComposeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const ComposeButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const Key('messaging_compose_floating_action_button'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: const Icon(Icons.edit_outlined),
    );
  }
}
